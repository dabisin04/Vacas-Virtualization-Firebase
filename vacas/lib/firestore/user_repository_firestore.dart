// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import 'package:vacas/domain/entities/user.dart';
import 'package:vacas/domain/repositories/user_repository.dart';

class UserRepositoryFirestore implements UserRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth auth = fb.FirebaseAuth.instance;

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
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 8)); // ⏱️ Tiempo máximo de espera

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Usuario sincronizado con API');
      } else {
        print('❌ Error en API: ${response.body}');
      }
    } catch (e) {
      print('⚠️ API no respondió en 8s o falló: $e');
    }
  }

  @override
  Future<void> createUser(Usuario user) async {
    if (user.password == null) {
      throw Exception('La contraseña es requerida para crear el usuario');
    }
    await registerUserWithAuthAndFirestore(user, user.password);
  }

  Future<void> registerUserWithAuthAndFirestore(
      Usuario user, String password) async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      final firebaseUser = result.user;
      if (firebaseUser == null) throw Exception('Fallo al registrar usuario');

      final newUser = user.copyWith(id: firebaseUser.uid);

      await firestore
          .collection('usuarios')
          .doc(newUser.id)
          .set(newUser.toJson());
      print('✅ Guardado en Firestore');

      final db = await _db;
      await db.insert('usuarios', newUser.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print('✅ Guardado en SQLite');

      await _tryPostToApi('addUsuario', newUser.toJson());

      await SessionService.saveUsuario(newUser);
      print('✅ Sesión iniciada');
    } catch (e) {
      print('❌ Error al registrar usuario: $e');
      rethrow;
    }
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = result.user;
      if (firebaseUser == null) throw Exception('Fallo en la autenticación');

      final doc =
          await firestore.collection('usuarios').doc(firebaseUser.uid).get();
      if (!doc.exists) throw Exception('Usuario no encontrado en Firestore');

      final user = Usuario.fromJson(doc.data()!);

      final db = await _db;
      await db.insert('usuarios', user.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      await SessionService.saveUsuario(user);
      print('✅ Login exitoso');
    } catch (e) {
      throw Exception('❌ Login fallido: $e');
    }
  }

  @override
  Future<void> logout() async {
    await auth.signOut();
    await SessionService.clearSession();
  }

  @override
  Future<Usuario?> getCurrentSession() async {
    return await SessionService.getUsuario();
  }

  @override
  Future<bool> isLoggedIn() async {
    return auth.currentUser != null && await SessionService.isLoggedIn();
  }

  @override
  Future<void> updateUser(Usuario user) async {
    try {
      await firestore.collection('usuarios').doc(user.id).update(user.toJson());

      final db = await _db;
      await db.update('usuarios', user.toJson(),
          where: 'id = ?', whereArgs: [user.id]);

      await _tryPostToApi('updateUsuario/${user.id}', user.toJson());

      print('✅ Usuario actualizado');
    } catch (e) {
      print('❌ Error al actualizar usuario: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await firestore.collection('usuarios').doc(id).delete();
      final db = await _db;
      await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
      await db.delete('usuario_finca', where: 'user_id = ?', whereArgs: [id]);

      try {
        final uri = Uri.parse('${ApiConstants.baseUrl}deleteUsuario/$id');
        await http.delete(uri);
        print('✅ Usuario eliminado en API');
      } catch (_) {
        print('⚠️ No se eliminó en API');
      }

      print('✅ Usuario eliminado en Firestore y local');
    } catch (e) {
      print('❌ Error al eliminar usuario: $e');
    }
  }

  @override
  Future<Usuario?> getUserById(String id) async {
    try {
      final doc = await firestore.collection('usuarios').doc(id).get();
      return doc.exists ? Usuario.fromJson(doc.data()!) : null;
    } catch (e) {
      print('❌ Error al obtener usuario por ID: $e');
      return null;
    }
  }

  @override
  Future<List<Usuario>> getAllUsers() async {
    try {
      final snapshot = await firestore.collection('usuarios').get();
      return snapshot.docs.map((doc) => Usuario.fromJson(doc.data())).toList();
    } catch (e) {
      print('❌ Error al obtener usuarios: $e');
      return [];
    }
  }

  @override
  Future<List<Usuario>> getUsersByFinca(String farmId) async {
    try {
      final snapshot = await firestore
          .collection('usuarios')
          .where('fincas', arrayContains: farmId)
          .get();
      return snapshot.docs.map((doc) => Usuario.fromJson(doc.data())).toList();
    } catch (e) {
      print('❌ Error al obtener usuarios por finca: $e');
      return [];
    }
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;
    final db = await _db;
    final users = await db.query('usuarios');
    for (var user in users) {
      await _tryPostToApi('addUsuario', user);
    }
  }
}
