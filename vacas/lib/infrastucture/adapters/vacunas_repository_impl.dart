import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/entities/vacuna.dart';
import '../../../../domain/repositories/vacuna_repository.dart';

class VacunaRepositoryImpl implements VacunaRepository {
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
        print('❌ Falló sincronización de vacuna: ${response.body}');
      } else {
        print('✅ Vacuna sincronizada con API');
      }
    } catch (_) {
      print('⏱️ Timeout o error al sincronizar vacuna con API');
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
      print('✅ Vacuna sincronizada con Firebase');
    } catch (e) {
      print('⏱️ Error al sincronizar vacuna con Firebase: $e');
    }
  }

  @override
  Future<void> addVacuna(Vacuna vacuna) async {
    final db = await _db;
    await db.insert(
      'vacunas',
      vacuna.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (await _isOnline()) {
      _tryPostToApi('addVacuna', vacuna.toJson());
      _tryPostToFirebase('vacunas', vacuna.toJson(), docId: vacuna.id);
    }
  }

  @override
  Future<void> updateVacuna(Vacuna vacuna) async {
    final db = await _db;
    await db.update(
      'vacunas',
      vacuna.toJson(),
      where: 'id = ?',
      whereArgs: [vacuna.id],
    );

    if (await _isOnline()) {
      _tryPostToApi('updateVacuna/${vacuna.id}', vacuna.toJson());
      _tryPostToFirebase('vacunas', vacuna.toJson(), docId: vacuna.id);
    }
  }

  @override
  Future<void> deleteVacuna(String id) async {
    final db = await _db;
    await db.delete(
      'vacunas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (await _isOnline()) {
      try {
        final uri = Uri.parse('${ApiConstants.baseUrl}deleteVacuna/$id');
        await http.delete(uri).timeout(const Duration(seconds: 10));
        print('✅ Vacuna eliminada también en API');
      } catch (_) {
        print('⏱️ Timeout o fallo al eliminar vacuna en API');
      }

      try {
        await FirebaseFirestore.instance.collection('vacunas').doc(id).delete();
        print('✅ Vacuna eliminada también de Firebase');
      } catch (_) {
        print('⏱️ Timeout o fallo al eliminar vacuna en Firebase');
      }
    }
  }

  @override
  Future<List<Vacuna>> getVacunasByAnimal(String animalId) async {
    final db = await _db;
    final maps = await db.query(
      'vacunas',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );

    return maps.map((map) => Vacuna.fromJson(map)).toList();
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;

    final db = await _db;
    final localVacunas = await db.query('vacunas');
    final localVacunasMap = {
      for (var vac in localVacunas) vac['id'] as String: vac
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllVacunas'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiVacunas =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot = await _firestore.collection('vacunas').get();
        final firestoreVacunas = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiVac in apiVacunas) {
          final vacId = apiVac['id'] as String;
          final localVac = localVacunasMap[vacId];
          final firestoreVac = firestoreVacunas
              .firstWhere((v) => v['id'] == vacId, orElse: () => {});

          // Si la vacuna no existe localmente, agregarla
          if (localVac == null) {
            await db.insert('vacunas', apiVac,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Vacuna sincronizada desde API: $vacId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localVac['updated_at'] as int? ?? 0;
            final apiTimestamp = apiVac['updated_at'] as int? ?? 0;
            final firestoreTimestamp = firestoreVac['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('vacunas', apiVac,
                  where: 'id = ?', whereArgs: [vacId]);
              print('✅ Vacuna actualizada desde API: $vacId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('vacunas', firestoreVac,
                  where: 'id = ?', whereArgs: [vacId]);
              print('✅ Vacuna actualizada desde Firestore: $vacId');
            }
          }
        }

        // Sincronizar datos locales que no existen en el servidor
        for (var localVac in localVacunas) {
          final vacId = localVac['id'] as String;
          final existsInApi = apiVacunas.any((v) => v['id'] == vacId);
          final existsInFirestore =
              firestoreVacunas.any((v) => v['id'] == vacId);

          if (!existsInApi && !existsInFirestore) {
            await _tryPostToApi('addVacuna', localVac);
            print('✅ Vacuna local sincronizada con servidor: $vacId');
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
