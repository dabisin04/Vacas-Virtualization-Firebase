import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final String apiUrl = ApiConstants.baseUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Database> get _db async => await SQLiteService.instance;

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _tryPostToApi(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(data))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Error sincronizando usuario: ${response.body}');
      } else {
        print('✅ Usuario sincronizado con API');
      }
    } catch (e) {
      print('⏱️ Error silencioso: no se pudo sincronizar con API → $e');
    }
  }

  @override
  Future<void> createUser(Usuario user) async {
    final db = await _db;
    await db.insert(
      'usuarios',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 🔸 Intentar sincronizar con API sin romper flujo
    _tryPostToApi('addUsuario', user.toJson());
  }

  @override
  Future<void> updateUser(Usuario user) async {
    final db = await _db;
    await db.update(
      'usuarios',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );

    _tryPostToApi('updateUsuario/${user.id}', user.toJson());
  }

  @override
  Future<void> deleteUser(String id) async {
    final db = await _db;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
    await db.delete('usuario_finca', where: 'user_id = ?', whereArgs: [id]);

    // 🔸 No interrumpas aunque falle
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}deleteUsuario/$id');
      await http.delete(uri).timeout(const Duration(seconds: 10));
      print('✅ Usuario eliminado de API');
    } catch (_) {
      print('⏱️ No se pudo eliminar en API, pero local OK');
    }
  }

  @override
  Future<Usuario?> getUserById(String id) async {
    final db = await _db;
    final result = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Usuario.fromJson(result.first) : null;
  }

  @override
  Future<List<Usuario>> getAllUsers() async {
    final db = await _db;
    final result = await db.query('usuarios');
    return result.map((e) => Usuario.fromJson(e)).toList();
  }

  @override
  Future<List<Usuario>> getUsersByFinca(String farmId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT u.* FROM usuarios u
      JOIN usuario_finca uf ON u.id = uf.user_id
      WHERE uf.farm_id = ?
    ''', [farmId]);
    return result.map((e) => Usuario.fromJson(e)).toList();
  }

  @override
  Future<void> login(String email, String password) async {
    if (await _isOnline()) {
      try {
        final uri = Uri.parse('${ApiConstants.baseUrl}login');
        final response = await http
            .post(uri,
                headers: {'Content-Type': 'application/json'},
                body: json.encode({"email": email, "password": password}))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final user = Usuario.fromJson(json.decode(response.body));
          await SessionService.saveUsuario(user);
          final db = await _db;
          await db.insert('usuarios', user.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          return;
        }
      } catch (_) {
        print('⏱️ Login remoto fallido, intentando offline...');
      }
    }

    // 🔸 Modo offline (o fallback)
    final db = await _db;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      final user = Usuario.fromJson(result.first);
      await SessionService.saveUsuario(user);
    } else {
      throw Exception('Usuario no encontrado (offline)');
    }
  }

  @override
  Future<void> logout() async {
    await SessionService.clearSession();
  }

  @override
  Future<Usuario?> getCurrentSession() async {
    return await SessionService.getUsuario();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await SessionService.isLoggedIn();
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;

    final db = await _db;
    final localUsers = await db.query('usuarios');
    final localUsersMap = {
      for (var user in localUsers) user['id'] as String: user
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllUsers'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiUsers =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot = await _firestore.collection('usuarios').get();
        final firestoreUsers = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiUser in apiUsers) {
          final userId = apiUser['id'] as String;
          final localUser = localUsersMap[userId];
          final firestoreUser = firestoreUsers
              .firstWhere((u) => u['id'] == userId, orElse: () => {});

          // Si el usuario no existe localmente, agregarlo
          if (localUser == null) {
            await db.insert('usuarios', apiUser,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Usuario sincronizado desde API: $userId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localUser['updated_at'] as int? ?? 0;
            final apiTimestamp = apiUser['updated_at'] as int? ?? 0;
            final firestoreTimestamp = firestoreUser['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('usuarios', apiUser,
                  where: 'id = ?', whereArgs: [userId]);
              print('✅ Usuario actualizado desde API: $userId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('usuarios', firestoreUser,
                  where: 'id = ?', whereArgs: [userId]);
              print('✅ Usuario actualizado desde Firestore: $userId');
            }
          }
        }

        // Sincronizar datos locales que no existen en el servidor
        for (var localUser in localUsers) {
          final userId = localUser['id'] as String;
          final existsInApi = apiUsers.any((u) => u['id'] == userId);
          final existsInFirestore =
              firestoreUsers.any((u) => u['id'] == userId);

          if (!existsInApi && !existsInFirestore) {
            await _tryPostToApi('addUsuario', localUser);
            print('✅ Usuario local sincronizado con servidor: $userId');
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
