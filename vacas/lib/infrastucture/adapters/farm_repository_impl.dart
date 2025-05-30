import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/farm.dart';
import '../../../domain/repositories/farm_repository.dart';

class FarmRepositoryImpl implements FarmRepository {
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
        print('❌ Falló sincronización finca: ${response.body}');
      }
    } catch (e) {
      print('⏱️ Error silencioso al sincronizar finca: $e');
    }
  }

  @override
  Future<void> createFarm(Farm farm) async {
    final db = await _db;
    await db.insert(
      'farms',
      farm.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _tryPostToApi('addFarm', farm.toJson());
  }

  @override
  Future<void> updateFarm(Farm farm) async {
    final db = await _db;
    await db.update(
      'farms',
      farm.toJson(),
      where: 'id = ?',
      whereArgs: [farm.id],
    );
    _tryPostToApi('updateFarm/${farm.id}', farm.toJson());
  }

  @override
  Future<void> deleteFarm(String id) async {
    final db = await _db;
    await db.delete('farms', where: 'id = ?', whereArgs: [id]);
    await db.delete('usuario_finca', where: 'farm_id = ?', whereArgs: [id]);

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}deleteFarm/$id');
      await http.delete(uri).timeout(const Duration(seconds: 10));
    } catch (_) {
      print('⏱️ Error silencioso al eliminar finca en API');
    }
  }

  @override
  Future<Farm?> getFarmById(String id) async {
    final db = await _db;
    final maps = await db.query('farms', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Farm.fromJson(maps.first) : null;
  }

  @override
  Future<List<Farm>> getFarmsByUser(String userId) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT f.* FROM farms f
      INNER JOIN usuario_finca uf ON f.id = uf.farm_id
      WHERE uf.user_id = ?
    ''', [userId]);

    return result.map((e) => Farm.fromJson(e)).toList();
  }

  @override
  Future<String> uploadFarmImage({
    required String farmId,
    required File imageFile,
  }) async {
    try {
      // Guardar localmente primero
      final dir = await getApplicationDocumentsDirectory();
      final localPath = '${dir.path}/$farmId.jpg';

      // Verificar si ya existe una imagen y eliminarla
      final existingFile = File(localPath);
      if (await existingFile.exists()) {
        await existingFile.delete();
      }

      // Verificar que el archivo de origen existe
      if (!await imageFile.exists()) {
        throw Exception('El archivo de imagen no existe');
      }

      final savedImage = await imageFile.copy(localPath);
      if (!await savedImage.exists()) {
        throw Exception('Error al guardar la imagen localmente');
      }

      // Actualizar la finca localmente con la ruta local
      final db = await _db;
      await db.update(
        'farms',
        {'local_foto_url': localPath},
        where: 'id = ?',
        whereArgs: [farmId],
      );

      // Subir al servidor
      final uri = Uri.parse('${ApiConstants.baseUrl}uploadFarmImage');
      final request = http.MultipartRequest('POST', uri)
        ..fields['farm_id'] = farmId
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: path.basename(imageFile.path),
          ),
        );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final url = data['url'];
        print('✅ Imagen subida. URL: $url');

        // Actualizar la finca con la URL del servidor
        await db.update(
          'farms',
          {'foto_url': url},
          where: 'id = ?',
          whereArgs: [farmId],
        );

        return url ?? '';
      } else {
        print('❌ Falló la subida de imagen: $body');
        return localPath; // Retornar la ruta local si falla la subida
      }
    } catch (e) {
      print('⚠️ Error al procesar imagen de finca: $e');
      return '';
    }
  }

  @override
  Future<void> syncWithServer() async {
    final db = await _db;
    final registros = await db.query('farms');

    for (var finca in registros) {
      try {
        // 🔁 Intenta sincronizar con la API REST
        _tryPostToApi('addFarm', finca);

        // 🔁 Si quieres añadir Firebase Firestore en el futuro:
        // await _tryPostToFirebase('farms', finca, docId: finca['id']);
      } catch (e) {
        print('⚠️ Error al sincronizar finca con ID ${finca['id']}: $e');
      }
    }

    print(
        '✅ Sincronización local de farms completada (API fallback tolerado).');
  }
}
