import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/evento_reproductivo.dart';
import '../../../domain/repositories/evento_reproductivo_repository.dart';

class EventoReproductivoRepositoryApi implements EventoReproductivoRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> addEvento(EventoReproductivo evento) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addEvento'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(evento.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al agregar evento reproductivo');
    }
  }

  @override
  Future<void> updateEvento(EventoReproductivo evento) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateEvento/${evento.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(evento.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar evento reproductivo');
    }
  }

  @override
  Future<void> deleteEvento(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteEvento/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar evento reproductivo');
    }
  }

  @override
  Future<List<EventoReproductivo>> getEventosByAnimal(String animalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/eventos/animal/$animalId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => EventoReproductivo.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener eventos por animal');
    }
  }

  @override
  Future<List<EventoReproductivo>> getEventosByFarm(String farmId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/eventos/farm/$farmId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => EventoReproductivo.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener eventos por finca');
    }
  }

  @override
  Future<List<EventoReproductivo>> getAllEventos() async {
    final response = await http.get(Uri.parse('$baseUrl/eventos'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => EventoReproductivo.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener todos los eventos reproductivos');
    }
  }

  @override
  Future<void> syncWithServer() async {
    // No aplica para modo API, se ignora o lanza error si se requiere
  }
}
