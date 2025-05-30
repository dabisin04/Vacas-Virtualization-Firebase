import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';

import '../../../domain/entities/peso.dart';
import '../../../domain/repositories/peso_repository.dart';

class PesoRepositoryImpl implements PesoRepository {
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
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Error al sincronizar peso: ${response.body}');
      }
    } catch (e) {
      print('⏱️ Sincronización de peso fallida (silenciosa): $e');
    }
  }

  @override
  Future<void> addPeso(Peso peso) async {
    final db = await _db;
    await db.insert(
      'pesos',
      peso.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _tryPostToApi('addPeso', peso.toJson());
  }

  @override
  Future<void> updatePeso(Peso peso) async {
    final db = await _db;
    await db.update(
      'pesos',
      peso.toJson(),
      where: 'id = ?',
      whereArgs: [peso.id],
    );
    _tryPostToApi('updatePeso/${peso.id}', peso.toJson());
  }

  @override
  Future<void> deletePeso(String id) async {
    final db = await _db;
    await db.delete('pesos', where: 'id = ?', whereArgs: [id]);
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}deletePeso/$id');
      await http.delete(uri).timeout(const Duration(seconds: 10));
    } catch (_) {
      print('⏱️ Error silencioso al eliminar peso en la API');
    }
  }

  @override
  Future<List<Peso>> getPesosByAnimal(String animalId) async {
    final db = await _db;
    final maps = await db.query(
      'pesos',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
    return maps.map((e) => Peso.fromJson(e)).toList();
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;

    final db = await _db;
    final localPesos = await db.query('pesos');
    final localPesosMap = {
      for (var peso in localPesos) peso['id'] as String: peso
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllPesos'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiPesos =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot = await _firestore.collection('pesos').get();
        final firestorePesos = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiPeso in apiPesos) {
          final pesoId = apiPeso['id'] as String;
          final localPeso = localPesosMap[pesoId];
          final firestorePeso = firestorePesos
              .firstWhere((p) => p['id'] == pesoId, orElse: () => {});

          // Si el peso no existe localmente, agregarlo
          if (localPeso == null) {
            await db.insert('pesos', apiPeso,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Peso sincronizado desde API: $pesoId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localPeso['updated_at'] as int? ?? 0;
            final apiTimestamp = apiPeso['updated_at'] as int? ?? 0;
            final firestoreTimestamp = firestorePeso['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('pesos', apiPeso,
                  where: 'id = ?', whereArgs: [pesoId]);
              print('✅ Peso actualizado desde API: $pesoId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('pesos', firestorePeso,
                  where: 'id = ?', whereArgs: [pesoId]);
              print('✅ Peso actualizado desde Firestore: $pesoId');
            }
          }
        }

        // Sincronizar datos locales que no existen en el servidor
        for (var localPeso in localPesos) {
          final pesoId = localPeso['id'] as String;
          final existsInApi = apiPesos.any((p) => p['id'] == pesoId);
          final existsInFirestore =
              firestorePesos.any((p) => p['id'] == pesoId);

          if (!existsInApi && !existsInFirestore) {
            await _tryPostToApi('addPeso', localPeso);
            print('✅ Peso local sincronizado con servidor: $pesoId');
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
