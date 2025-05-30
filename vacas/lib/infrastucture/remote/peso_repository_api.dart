import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/peso.dart';
import '../../../domain/repositories/peso_repository.dart';

class PesoRepositoryApi implements PesoRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> addPeso(Peso peso) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addPeso'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(peso.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al registrar peso');
    }
  }

  @override
  Future<void> updatePeso(Peso peso) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updatePeso/${peso.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(peso.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar peso');
    }
  }

  @override
  Future<void> deletePeso(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deletePeso/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar peso');
    }
  }

  @override
  Future<List<Peso>> getPesosByAnimal(String animalId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/pesosByAnimal/$animalId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => Peso.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener pesos del animal');
    }
  }

  @override
  Future<void> syncWithServer() async {
    // No aplica en modo API
  }
}
