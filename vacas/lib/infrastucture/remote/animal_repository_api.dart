import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:vacas/core/constants/api_constants.dart';
import '../../../domain/entities/animal.dart';
import '../../../domain/repositories/animal_repository.dart';

class AnimalRepositoryApi implements AnimalRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<String> saveImageLocally(File imageFile, String animalId) async {
    final dir = await getApplicationDocumentsDirectory();
    final localPath = '${dir.path}/$animalId.jpg';
    final savedImage = await imageFile.copy(localPath);
    return savedImage.path;
  }

  @override
  Future<void> addAnimal(Animal animal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addAnimal'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(animal.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al agregar animal');
    }
  }

  @override
  Future<void> updateAnimal(Animal animal) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateAnimal/${animal.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(animal.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar animal');
    }
  }

  @override
  Future<void> deleteAnimal(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deleteAnimal/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar animal');
    }
  }

  @override
  Future<Animal?> getAnimalById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/animal/$id'));
    if (response.statusCode == 200) {
      return Animal.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener animal por ID');
    }
  }

  @override
  Future<List<Animal>> getAllAnimals({required String farmId}) async {
    final response =
        await http.get(Uri.parse('$baseUrl/animals?farm_id=$farmId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => Animal.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener lista de animales');
    }
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
    //
  }
}
