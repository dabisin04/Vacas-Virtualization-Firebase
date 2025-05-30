import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/chequeo_salud.dart';
import '../../../domain/repositories/chequeo_salud_repository.dart';

class ChequeoSaludRepositoryApi implements ChequeoSaludRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> addChequeo(ChequeoSalud chequeo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addChequeo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chequeo.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al agregar chequeo de salud');
    }
  }

  @override
  Future<void> updateChequeo(ChequeoSalud chequeo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateChequeo/${chequeo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chequeo.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar chequeo de salud');
    }
  }

  @override
  Future<void> deleteChequeo(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteChequeo/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar chequeo de salud');
    }
  }

  @override
  Future<List<ChequeoSalud>> getChequeosByAnimal(String animalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chequeos/$animalId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => ChequeoSalud.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener chequeos de salud');
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Este método puede ignorarse en modo API
  }
}
