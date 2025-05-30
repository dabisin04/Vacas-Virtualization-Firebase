import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import 'package:vacas/domain/entities/chequeo_salud.dart';
import 'package:vacas/domain/repositories/chequeo_salud_repository.dart';

class ChequeoSaludRepositoryImpl implements ChequeoSaludRepository {
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
      final uri = Uri.parse('$apiUrl$endpoint');
      final response = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(data))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Falló sincronización chequeo: ${response.body}');
      } else {
        print('✅ Chequeo sincronizado con API');
      }
    } catch (e) {
      print('⏱️ Error silencioso al sincronizar chequeo con API: $e');
    }
  }

  @override
  Future<void> addChequeo(ChequeoSalud chequeo) async {
    final db = await _db;
    await db.insert(
      'chequeos_salud',
      chequeo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _tryPostToApi('addChequeo', chequeo.toJson());
  }

  @override
  Future<void> updateChequeo(ChequeoSalud chequeo) async {
    final db = await _db;
    await db.update(
      'chequeos_salud',
      chequeo.toJson(),
      where: 'id = ?',
      whereArgs: [chequeo.id],
    );

    _tryPostToApi('updateChequeo/${chequeo.id}', chequeo.toJson());
  }

  @override
  Future<void> deleteChequeo(String id) async {
    final db = await _db;
    await db.delete('chequeos_salud', where: 'id = ?', whereArgs: [id]);

    try {
      if (await _isOnline()) {
        final uri = Uri.parse('${apiUrl}deleteChequeo/$id');
        await http.delete(uri).timeout(const Duration(seconds: 10));
        print('✅ Chequeo eliminado de API');
      }
    } catch (_) {
      print('⏱️ Error silencioso al eliminar chequeo en API');
    }
  }

  @override
  Future<List<ChequeoSalud>> getChequeosByAnimal(String animalId) async {
    final db = await _db;
    final maps = await db.query(
      'chequeos_salud',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );

    return maps.map((e) => ChequeoSalud.fromJson(e)).toList();
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;

    final db = await _db;
    final localChequeos = await db.query('chequeos_salud');
    final localChequeosMap = {
      for (var chequeo in localChequeos) chequeo['id'] as String: chequeo
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllChequeos'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiChequeos =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot =
            await _firestore.collection('chequeos_salud').get();
        final firestoreChequeos = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiChequeo in apiChequeos) {
          final chequeoId = apiChequeo['id'] as String;
          final localChequeo = localChequeosMap[chequeoId];
          final firestoreChequeo = firestoreChequeos
              .firstWhere((c) => c['id'] == chequeoId, orElse: () => {});

          // Si el chequeo no existe localmente, agregarlo
          if (localChequeo == null) {
            await db.insert('chequeos_salud', apiChequeo,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Chequeo sincronizado desde API: $chequeoId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localChequeo['updated_at'] as int? ?? 0;
            final apiTimestamp = apiChequeo['updated_at'] as int? ?? 0;
            final firestoreTimestamp =
                firestoreChequeo['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('chequeos_salud', apiChequeo,
                  where: 'id = ?', whereArgs: [chequeoId]);
              print('✅ Chequeo actualizado desde API: $chequeoId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('chequeos_salud', firestoreChequeo,
                  where: 'id = ?', whereArgs: [chequeoId]);
              print('✅ Chequeo actualizado desde Firestore: $chequeoId');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
