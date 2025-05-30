import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/session_service.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';

class UserRepositoryApi implements UserRepository {
  final String baseUrl = 'http://192.168.1.12:5001/api';

  @override
  Future<void> createUser(Usuario user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addUsuario'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear usuario');
    }
  }

  @override
  Future<void> updateUser(Usuario user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateUsuario/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deleteUsuario/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar usuario');
    }
  }

  @override
  Future<Usuario?> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/usuario/$id'));
    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener usuario');
    }
  }

  @override
  Future<List<Usuario>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  @override
  Future<List<Usuario>> getUsersByFinca(String farmId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/usuariosPorFinca/$farmId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener usuarios por finca');
    }
  }

  @override
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final user = Usuario.fromJson(json.decode(response.body));
      await SessionService.saveUsuario(user);
    } else {
      throw Exception('Usuario no encontrado');
    }
  }

  @override
  Future<void> logout() async {
    await SessionService.clearSession();
  }

  @override
  Future<Usuario?> getCurrentSession() async {
    return await SessionService.getUsuario();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await SessionService.isLoggedIn();
  }

  @override
  Future<void> syncWithServer() async {
    // Implementar sincronización con API
  }
}
