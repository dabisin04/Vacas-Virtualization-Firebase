import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import 'package:vacas/domain/entities/animal.dart';
import 'package:vacas/domain/repositories/animal_repository.dart';

class AnimalRepositoryImpl implements AnimalRepository {
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

  @override
  Future<String> saveImageLocally(File imageFile, String animalId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final localPath = '${dir.path}/$animalId.jpg';

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

      return savedImage.path;
    } catch (e) {
      print('❌ Error al guardar imagen localmente: $e');
      rethrow;
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
        print('❌ Falló la sincronización con API: ${response.body}');
      } else {
        print('✅ Animal sincronizado con API');
      }
    } catch (e) {
      print('⏱️ Error silencioso al sincronizar con API: $e');
    }
  }

  Future<void> _tryPutToApi(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$apiUrl$endpoint');
      final response = await http
          .put(uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(data))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Falló la sincronización con API: ${response.body}');
      }
    } catch (e) {
      print('⏱️ Error silencioso al sincronizar con API: $e');
    }
  }

  @override
  Future<void> addAnimal(Animal animal) async {
    final db = await _db;
    await db.insert(
      'animals',
      animal.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Intento silencioso de sincronización
    _tryPostToApi('addAnimal', animal.toJson());
  }

  @override
  Future<void> updateAnimal(Animal animal) async {
    final db = await _db;
    await db.update(
      'animals',
      animal.toJson(),
      where: 'id = ?',
      whereArgs: [animal.id],
    );

    // Crear una copia del JSON sin localFotoUrl para la API
    final jsonParaApi = Map<String, dynamic>.from(animal.toJson());
    jsonParaApi.remove('localFotoUrl');
    _tryPutToApi('updateAnimal/${animal.id}', jsonParaApi);
  }

  @override
  Future<void> deleteAnimal(String id) async {
    final db = await _db;
    await db.delete('animals', where: 'id = ?', whereArgs: [id]);

    try {
      if (await _isOnline()) {
        final uri = Uri.parse('${apiUrl}deleteAnimal/$id');
        await http.delete(uri).timeout(const Duration(seconds: 10));
        print('✅ Animal eliminado de API');
      }
    } catch (_) {
      print('⏱️ Error silencioso al eliminar animal en API');
    }
  }

  @override
  Future<Animal?> getAnimalById(String id) async {
    final db = await _db;
    final result = await db.query('animals', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Animal.fromJson(result.first) : null;
  }

  @override
  Future<List<Animal>> getAllAnimals({required String farmId}) async {
    final db = await _db;
    final result =
        await db.query('animals', where: 'farm_id = ?', whereArgs: [farmId]);
    return result.map((e) => Animal.fromJson(e)).toList();
  }

  @override
  Future<String> uploadAnimalImage({
    required String animalId,
    required File imageFile,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}uploadAnimalImage');
      final request = http.MultipartRequest('POST', uri)
        ..fields['animal_id'] = animalId
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
        return url ?? '';
      } else {
        print('❌ Falló la subida de imagen: $body');
        return '';
      }
    } catch (e) {
      print('⚠️ Error al subir imagen de animal: $e');
      return '';
    }
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;

    final db = await _db;
    final localAnimals = await db.query('animals');
    final localAnimalsMap = {
      for (var animal in localAnimals) animal['id'] as String: animal
    };

    try {
      // Obtener datos de la API
      final apiResponse = await http
          .get(Uri.parse('${apiUrl}getAllAnimals'))
          .timeout(const Duration(seconds: 10));

      if (apiResponse.statusCode == 200) {
        final apiAnimals =
            List<Map<String, dynamic>>.from(json.decode(apiResponse.body));

        // Obtener datos de Firestore
        final firestoreSnapshot = await _firestore.collection('animals').get();
        final firestoreAnimals = firestoreSnapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();

        // Comparar y actualizar datos
        for (var apiAnimal in apiAnimals) {
          final animalId = apiAnimal['id'] as String;
          final localAnimal = localAnimalsMap[animalId];
          final firestoreAnimal = firestoreAnimals
              .firstWhere((a) => a['id'] == animalId, orElse: () => {});

          // Si el animal no existe localmente, agregarlo
          if (localAnimal == null) {
            await db.insert('animals', apiAnimal,
                conflictAlgorithm: ConflictAlgorithm.replace);
            print('✅ Animal sincronizado desde API: $animalId');
          } else {
            // Comparar timestamps para determinar la versión más reciente
            final localTimestamp = localAnimal['updated_at'] as int? ?? 0;
            final apiTimestamp = apiAnimal['updated_at'] as int? ?? 0;
            final firestoreTimestamp =
                firestoreAnimal['updated_at'] as int? ?? 0;

            final latestTimestamp = [
              localTimestamp,
              apiTimestamp,
              firestoreTimestamp
            ].reduce((a, b) => a > b ? a : b);

            // Actualizar con la versión más reciente
            if (latestTimestamp == apiTimestamp) {
              await db.update('animals', apiAnimal,
                  where: 'id = ?', whereArgs: [animalId]);
              print('✅ Animal actualizado desde API: $animalId');
            } else if (latestTimestamp == firestoreTimestamp) {
              await db.update('animals', firestoreAnimal,
                  where: 'id = ?', whereArgs: [animalId]);
              print('✅ Animal actualizado desde Firestore: $animalId');
            }
          }
        }

        // Sincronizar imágenes
        for (var animal in localAnimals) {
          final animalId = animal['id'] as String;
          final localFotoUrl = animal['local_foto_url'] as String?;

          if (localFotoUrl != null && File(localFotoUrl).existsSync()) {
            final animalObj = Animal.fromJson(animal);
            await uploadAnimalImage(
              animalId: animalId,
              imageFile: File(localFotoUrl),
            );
            print('✅ Imagen sincronizada para animal: $animalId');
          }
        }
      }
    } catch (e) {
      print('❌ Error en sincronización avanzada: $e');
    }
  }
}
