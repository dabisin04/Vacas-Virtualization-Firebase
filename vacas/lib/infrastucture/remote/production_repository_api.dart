import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/produccion_leche.dart';
import '../../../domain/repositories/produccion_leche_repository.dart';

class ProduccionLecheRepositoryApi implements ProduccionLecheRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> addProduccion(ProduccionLeche produccion) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addProduccionLeche'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(produccion.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al registrar producción');
    }
  }

  @override
  Future<void> updateProduccion(ProduccionLeche produccion) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateProduccion/${produccion.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(produccion.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar producción');
    }
  }

  @override
  Future<void> deleteProduccion(String id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/deleteProduccion/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar producción');
    }
  }

  @override
  Future<List<ProduccionLeche>> getProduccionByAnimal(String animalId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/produccionByAnimal/$animalId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => ProduccionLeche.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener producción por animal');
    }
  }

  @override
  Future<List<ProduccionLeche>> getProduccionByFarm(String farmId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/produccionByFarm/$farmId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => ProduccionLeche.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener producción por finca');
    }
  }

  @override
  Future<List<ProduccionLeche>> getAllProduccion() async {
    final response = await http.get(Uri.parse('$baseUrl/produccionTotal'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => ProduccionLeche.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener toda la producción');
    }
  }

  @override
  Future<void> syncWithServer() async {
    // No aplica si ya está conectado directamente al backend
  }
}
