import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import '../../../domain/entities/usuario_finca.dart';
import '../../../domain/repositories/usuario_finca_repository.dart';

class UsuarioFincaRepositoryImpl implements UsuarioFincaRepository {
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
        print('❌ Falló sincronización usuario-finca: ${response.body}');
      } else {
        print('✅ Relación usuario-finca sincronizada con API');
      }
    } catch (_) {
      print('⏱️ Timeout o error al sincronizar relación usuario-finca con API');
    }
  }

  Future<void> _tryPostToFirebase(String collection, Map<String, dynamic> data,
      {String? docId}) async {
    try {
      final ref = FirebaseFirestore.instance.collection(collection);
      if (docId != null) {
        await ref.doc(docId).set(data);
      } else {
        await ref.add(data);
      }
      print('✅ Relación usuario-finca sincronizada con Firebase');
    } catch (e) {
      print('⏱️ Error al sincronizar con Firebase: $e');
    }
  }

  @override
  Future<void> asignarUsuarioAFinca(UsuarioFinca relacion) async {
    final db = await _db;
    await db.insert(
      'usuario_finca',
      relacion.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (await _isOnline()) {
      _tryPostToApi('asignarUsuarioAFinca', relacion.toJson());
      _tryPostToFirebase('usuario_finca', relacion.toJson(),
          docId: relacion.id);
    }
  }

  @override
  Future<List<String>> getFincaIdsByUsuario(String userId) async {
    final db = await _db;
    final result = await db.query(
      'usuario_finca',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => e['farm_id'] as String).toList();
  }

  @override
  Future<List<String>> getUsuarioIdsByFinca(String farmId) async {
    final db = await _db;
    final result = await db.query(
      'usuario_finca',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return result.map((e) => e['user_id'] as String).toList();
  }

  @override
  Future<void> eliminarRelacion(String id) async {
    final db = await _db;
    await db.delete(
      'usuario_finca',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (await _isOnline()) {
      try {
        final uri = Uri.parse('${ApiConstants.baseUrl}eliminarRelacion/$id');
        await http.delete(uri).timeout(const Duration(seconds: 10));
        print('✅ Relación usuario-finca eliminada de API');
      } catch (_) {
        print(
            '⏱️ No se pudo eliminar en API, pero en SQLite ya está eliminada');
      }

      try {
        await FirebaseFirestore.instance
            .collection('usuario_finca')
            .doc(id)
            .delete();
        print('✅ Relación usuario-finca eliminada de Firebase');
      } catch (_) {
        print('⏱️ Error al eliminar en Firebase');
      }
    }
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) {
      print('🌐 Sin conexión, no se puede sincronizar usuario-finca.');
      return;
    }

    final db = await _db;
    final localRelaciones = await db.query('usuario_finca');
    final localRelacionesMap = {
      for (var rel in localRelaciones) rel['id'] as String: rel
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllUsuarioFinca'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiRelaciones =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot =
            await _firestore.collection('usuario_finca').get();
        final firestoreRelaciones = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiRel in apiRelaciones) {
          final relId = apiRel['id'] as String;
          final localRel = localRelacionesMap[relId];
          final firestoreRel = firestoreRelaciones
              .firstWhere((r) => r['id'] == relId, orElse: () => {});

          // Si la relación no existe localmente, agregarla
          if (localRel == null) {
            await db.insert('usuario_finca', apiRel,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Relación usuario-finca sincronizada desde API: $relId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localRel['updated_at'] as int? ?? 0;
            final apiTimestamp = apiRel['updated_at'] as int? ?? 0;
            final firestoreTimestamp = firestoreRel['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('usuario_finca', apiRel,
                  where: 'id = ?', whereArgs: [relId]);
              print('✅ Relación usuario-finca actualizada desde API: $relId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('usuario_finca', firestoreRel,
                  where: 'id = ?', whereArgs: [relId]);
              print(
                  '✅ Relación usuario-finca actualizada desde Firestore: $relId');
            }
          }
        }

        // Sincronizar datos locales que no existen en el servidor
        for (var localRel in localRelaciones) {
          final relId = localRel['id'] as String;
          final existsInApi = apiRelaciones.any((r) => r['id'] == relId);
          final existsInFirestore =
              firestoreRelaciones.any((r) => r['id'] == relId);

          if (!existsInApi && !existsInFirestore) {
            await _tryPostToApi('asignarUsuarioAFinca', localRel);
            print(
                '✅ Relación usuario-finca local sincronizada con servidor: $relId');
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
