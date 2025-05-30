import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';

import '../../../domain/entities/evento_reproductivo.dart';
import '../../../domain/repositories/evento_reproductivo_repository.dart';

class EventoReproductivoRepositoryImpl implements EventoReproductivoRepository {
  final String apiUrl = ApiConstants.baseUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Database> get _db async => await SQLiteService.instance;

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
        print('❌ Falló sincronización evento: ${response.body}');
      }
    } catch (e) {
      print('⏱️ Error silencioso al sincronizar evento: $e');
    }
  }

  @override
  Future<void> addEvento(EventoReproductivo evento) async {
    final db = await _db;
    await db.insert('eventos_reproductivos', evento.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    _tryPostToApi('addEvento', evento.toJson());
  }

  @override
  Future<void> updateEvento(EventoReproductivo evento) async {
    final db = await _db;
    await db.update('eventos_reproductivos', evento.toJson(),
        where: 'id = ?', whereArgs: [evento.id]);
    _tryPostToApi('updateEvento/${evento.id}', evento.toJson());
  }

  @override
  Future<void> deleteEvento(String id) async {
    final db = await _db;
    await db.delete('eventos_reproductivos', where: 'id = ?', whereArgs: [id]);
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}deleteEvento/$id');
      await http.delete(uri).timeout(const Duration(seconds: 10));
    } catch (_) {
      print('⏱️ Error silencioso al eliminar evento en API');
    }
  }

  @override
  Future<List<EventoReproductivo>> getEventosByAnimal(String animalId) async {
    final db = await _db;
    final maps = await db.query(
      'eventos_reproductivos',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
    return maps.map(EventoReproductivo.fromJson).toList();
  }

  @override
  Future<List<EventoReproductivo>> getEventosByFarm(String farmId) async {
    final db = await _db;
    final maps = await db.query(
      'eventos_reproductivos',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return maps.map(EventoReproductivo.fromJson).toList();
  }

  @override
  Future<List<EventoReproductivo>> getAllEventos() async {
    final db = await _db;
    final maps = await db.query('eventos_reproductivos');
    return maps.map(EventoReproductivo.fromJson).toList();
  }

  @override
  Future<void> syncWithServer() async {
    final db = await _db;
    final localEventos = await db.query('eventos_reproductivos');
    final localEventosMap = {
      for (var evento in localEventos) evento['id'] as String: evento
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllEventos'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiEventos =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot =
            await _firestore.collection('eventos_reproductivos').get();
        final firestoreEventos = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiEvento in apiEventos) {
          final eventoId = apiEvento['id'] as String;
          final localEvento = localEventosMap[eventoId];
          final firestoreEvento = firestoreEventos
              .firstWhere((e) => e['id'] == eventoId, orElse: () => {});

          // Si el evento no existe localmente, agregarlo
          if (localEvento == null) {
            await db.insert('eventos_reproductivos', apiEvento,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Evento sincronizado desde API: $eventoId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localEvento['updated_at'] as int? ?? 0;
            final apiTimestamp = apiEvento['updated_at'] as int? ?? 0;
            final firestoreTimestamp =
                firestoreEvento['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('eventos_reproductivos', apiEvento,
                  where: 'id = ?', whereArgs: [eventoId]);
              print('✅ Evento actualizado desde API: $eventoId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('eventos_reproductivos', firestoreEvento,
                  where: 'id = ?', whereArgs: [eventoId]);
              print('✅ Evento actualizado desde Firestore: $eventoId');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
