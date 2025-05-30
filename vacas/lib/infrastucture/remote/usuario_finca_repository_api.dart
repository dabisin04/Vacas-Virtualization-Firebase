import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/usuario_finca.dart';
import '../../../domain/repositories/usuario_finca_repository.dart';

class UsuarioFincaRepositoryApi implements UsuarioFincaRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> asignarUsuarioAFinca(UsuarioFinca relacion) async {
    final response = await http.post(
      Uri.parse('$baseUrl/asignarUsuarioAFinca'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(relacion.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al asignar usuario a finca');
    }
  }

  @override
  Future<List<String>> getFincaIdsByUsuario(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/fincasPorUsuario/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Error al obtener fincas del usuario');
    }
  }

  @override
  Future<List<String>> getUsuarioIdsByFinca(String farmId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/usuariosPorFinca/$farmId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Error al obtener usuarios de la finca');
    }
  }

  @override
  Future<void> eliminarRelacion(String id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/eliminarRelacion/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar relación');
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Implementar sincronización con API
  }
}
