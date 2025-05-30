import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/vacuna.dart';
import '../../../domain/repositories/vacuna_repository.dart';

class VacunaRepositoryApi implements VacunaRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> addVacuna(Vacuna vacuna) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addVacuna'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vacuna.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al agregar vacuna');
    }
  }

  @override
  Future<void> updateVacuna(Vacuna vacuna) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateVacuna/${vacuna.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vacuna.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar vacuna');
    }
  }

  @override
  Future<void> deleteVacuna(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteVacuna/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar vacuna');
    }
  }

  @override
  Future<List<Vacuna>> getVacunasByAnimal(String animalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/vacunas/$animalId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Vacuna.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener vacunas del animal');
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Vacío para implementación futura
    return;
  }
}
