import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import '../../../domain/entities/tratamiento.dart';
import '../../../domain/repositories/tratamiento_repository.dart';

class TratamientoRepositoryImpl implements TratamientoRepository {
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
      print('⏱️ Fallo silencioso al sincronizar tratamiento');
    }
  }

  @override
  Future<void> addTratamiento(Tratamiento tratamiento) async {
    final db = await _db;
    await db.insert(
      'tratamientos',
      tratamiento.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _tryPostToApi('addTratamiento', tratamiento.toJson());
  }

  @override
  Future<void> updateTratamiento(Tratamiento tratamiento) async {
    final db = await _db;
    await db.update(
      'tratamientos',
      tratamiento.toJson(),
      where: 'id = ?',
      whereArgs: [tratamiento.id],
    );
    _tryPostToApi('updateTratamiento/${tratamiento.id}', tratamiento.toJson());
  }

  @override
  Future<void> deleteTratamiento(String id) async {
    final db = await _db;
    await db.delete('tratamientos', where: 'id = ?', whereArgs: [id]);
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}deleteTratamiento/$id');
      await http.delete(uri).timeout(const Duration(seconds: 10));
    } catch (_) {
      print('⏱️ Fallo silencioso al eliminar tratamiento en API');
    }
  }

  @override
  Future<List<Tratamiento>> getTratamientosByAnimal(String animalId) async {
    final db = await _db;
    final maps = await db.query(
      'tratamientos',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
    return maps.map((e) => Tratamiento.fromJson(e)).toList();
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;

    final db = await _db;
    final localTratamientos = await db.query('tratamientos');
    final localTratamientosMap = {
      for (var trat in localTratamientos) trat['id'] as String: trat
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllTratamientos'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiTratamientos =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot =
            await _firestore.collection('tratamientos').get();
        final firestoreTratamientos = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiTrat in apiTratamientos) {
          final tratId = apiTrat['id'] as String;
          final localTrat = localTratamientosMap[tratId];
          final firestoreTrat = firestoreTratamientos
              .firstWhere((t) => t['id'] == tratId, orElse: () => {});

          // Si el tratamiento no existe localmente, agregarlo
          if (localTrat == null) {
            await db.insert('tratamientos', apiTrat,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Tratamiento sincronizado desde API: $tratId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localTrat['updated_at'] as int? ?? 0;
            final apiTimestamp = apiTrat['updated_at'] as int? ?? 0;
            final firestoreTimestamp = firestoreTrat['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('tratamientos', apiTrat,
                  where: 'id = ?', whereArgs: [tratId]);
              print('✅ Tratamiento actualizado desde API: $tratId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('tratamientos', firestoreTrat,
                  where: 'id = ?', whereArgs: [tratId]);
              print('✅ Tratamiento actualizado desde Firestore: $tratId');
            }
          }
        }

        // Sincronizar datos locales que no existen en el servidor
        for (var localTrat in localTratamientos) {
          final tratId = localTrat['id'] as String;
          final existsInApi = apiTratamientos.any((t) => t['id'] == tratId);
          final existsInFirestore =
              firestoreTratamientos.any((t) => t['id'] == tratId);

          if (!existsInApi && !existsInFirestore) {
            await _tryPostToApi('addTratamiento', localTrat);
            print('✅ Tratamiento local sincronizado con servidor: $tratId');
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
