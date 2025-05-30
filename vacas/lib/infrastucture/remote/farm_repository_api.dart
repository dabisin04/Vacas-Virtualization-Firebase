import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../../../domain/entities/farm.dart';
import '../../../domain/repositories/farm_repository.dart';
import '../../../core/constants/api_constants.dart';

class FarmRepositoryApi implements FarmRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> createFarm(Farm farm) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addFarm'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(farm.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear la finca');
    }
  }

  @override
  Future<void> updateFarm(Farm farm) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateFarm/${farm.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(farm.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la finca');
    }
  }

  @override
  Future<void> deleteFarm(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deleteFarm/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la finca');
    }
  }

  @override
  Future<Farm?> getFarmById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/farm/$id'));
    if (response.statusCode == 200) {
      return Farm.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener finca por ID');
    }
  }

  @override
  Future<List<Farm>> getFarmsByUser(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/farmsByUser/$userId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => Farm.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener fincas del usuario');
    }
  }

  @override
  Future<String> uploadFarmImage({
    required String farmId,
    required File imageFile,
  }) async {
    try {
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
        final url =
            data['url']; // asegúrate de que tu backend retorne este campo
        print('✅ Imagen subida. URL: $url');
        return url ?? '';
      } else {
        print('❌ Falló la subida de imagen: $body');
        return '';
      }
    } catch (e) {
      print('⚠️ Error al subir imagen de finca: $e');
      return '';
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Implementar sincronización con API
  }
}
