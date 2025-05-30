import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/tratamiento.dart';
import '../../../domain/repositories/tratamiento_repository.dart';

class TratamientoRepositoryApi implements TratamientoRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> addTratamiento(Tratamiento tratamiento) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addTratamiento'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tratamiento.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al registrar tratamiento');
    }
  }

  @override
  Future<void> updateTratamiento(Tratamiento tratamiento) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateTratamiento/${tratamiento.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tratamiento.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar tratamiento');
    }
  }

  @override
  Future<void> deleteTratamiento(String id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/deleteTratamiento/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar tratamiento');
    }
  }

  @override
  Future<List<Tratamiento>> getTratamientosByAnimal(String animalId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/tratamientosByAnimal/$animalId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => Tratamiento.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener tratamientos del animal');
    }
  }

  @override
  Future<void> syncWithServer() async {
    // No se aplica en modo API
  }
}
