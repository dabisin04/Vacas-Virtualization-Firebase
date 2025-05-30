import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';

import '../../domain/entities/produccion_leche.dart';
import '../../domain/repositories/produccion_leche_repository.dart';

class ProduccionLecheRepositoryImpl implements ProduccionLecheRepository {
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
      await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(data))
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      print('⏱️ Fallo silencioso al sincronizar producción');
    }
  }

  @override
  Future<void> addProduccion(ProduccionLeche produccion) async {
    final db = await _db;
    await db.insert(
      'produccion_leche',
      produccion.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _tryPostToApi('addProduccionLeche', produccion.toJson());
  }

  @override
  Future<void> updateProduccion(ProduccionLeche produccion) async {
    final db = await _db;
    await db.update(
      'produccion_leche',
      produccion.toJson(),
      where: 'id = ?',
      whereArgs: [produccion.id],
    );
    _tryPostToApi('updateProduccion/${produccion.id}', produccion.toJson());
  }

  @override
  Future<void> deleteProduccion(String id) async {
    final db = await _db;
    await db.delete('produccion_leche', where: 'id = ?', whereArgs: [id]);
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}deleteProduccion/$id');
      await http.delete(uri).timeout(const Duration(seconds: 10));
    } catch (_) {
      print('⏱️ Fallo silencioso al eliminar producción en API');
    }
  }

  @override
  Future<List<ProduccionLeche>> getProduccionByAnimal(String animalId) async {
    final db = await _db;
    final maps = await db.query(
      'produccion_leche',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
    return maps.map((e) => ProduccionLeche.fromJson(e)).toList();
  }

  @override
  Future<List<ProduccionLeche>> getAllProduccion() async {
    final db = await _db;
    final result = await db.query('produccion_leche');
    return result.map((e) => ProduccionLeche.fromJson(e)).toList();
  }

  @override
  Future<List<ProduccionLeche>> getProduccionByFarm(String farmId) async {
    final db = await _db;
    final result = await db.query(
      'produccion_leche',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return result.map((e) => ProduccionLeche.fromJson(e)).toList();
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;

    final db = await _db;
    final localProducciones = await db.query('produccion_leche');
    final localProduccionesMap = {
      for (var prod in localProducciones) prod['id'] as String: prod
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllProduccion'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiProducciones =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot =
            await _firestore.collection('produccion_leche').get();
        final firestoreProducciones = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiProd in apiProducciones) {
          final prodId = apiProd['id'] as String;
          final localProd = localProduccionesMap[prodId];
          final firestoreProd = firestoreProducciones
              .firstWhere((p) => p['id'] == prodId, orElse: () => {});

          // Si la producción no existe localmente, agregarla
          if (localProd == null) {
            await db.insert('produccion_leche', apiProd,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Producción sincronizada desde API: $prodId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localProd['updated_at'] as int? ?? 0;
            final apiTimestamp = apiProd['updated_at'] as int? ?? 0;
            final firestoreTimestamp = firestoreProd['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('produccion_leche', apiProd,
                  where: 'id = ?', whereArgs: [prodId]);
              print('✅ Producción actualizada desde API: $prodId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('produccion_leche', firestoreProd,
                  where: 'id = ?', whereArgs: [prodId]);
              print('✅ Producción actualizada desde Firestore: $prodId');
            }
          }
        }

        // Sincronizar datos locales que no existen en el servidor
        for (var localProd in localProducciones) {
          final prodId = localProd['id'] as String;
          final existsInApi = apiProducciones.any((p) => p['id'] == prodId);
          final existsInFirestore =
              firestoreProducciones.any((p) => p['id'] == prodId);

          if (!existsInApi && !existsInFirestore) {
            await _tryPostToApi('addProduccionLeche', localProd);
            print('✅ Producción local sincronizada con servidor: $prodId');
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
