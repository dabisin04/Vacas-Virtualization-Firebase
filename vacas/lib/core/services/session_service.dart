import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacas/domain/entities/usuario_finca.dart';
import 'package:vacas/domain/enums/rol_usuario.dart';
import '../../domain/entities/user.dart';

class SessionService {
  static const String _keyUsuario = 'session_usuario';
  static const String _keyFincaSeleccionada = 'selected_farm_id';

  // Guardar usuario completo como JSON
  static Future<void> saveUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = jsonEncode(usuario.toJson());
    await prefs.setString(_keyUsuario, usuarioJson);
  }

  // Obtener usuario desde SharedPreferences
  static Future<Usuario?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioString = prefs.getString(_keyUsuario);

    if (usuarioString == null || usuarioString.isEmpty) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(usuarioString);
      return Usuario.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isAdmin() async {
    final usuario = await getUsuario();
    return usuario?.rol == RolUsuario.administrador;
  }

  // Eliminar usuario y finca seleccionada
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuario);
    await prefs.remove(_keyFincaSeleccionada);
  }

  // Verificar si hay sesión iniciada
  static Future<bool> isLoggedIn() async {
    final usuario = await getUsuario();
    return usuario != null;
  }

  // Guardar finca seleccionada
  static Future<void> setFincaSeleccionada(String farmId) async {
    if (farmId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFincaSeleccionada, farmId);
  }

  // Obtener finca seleccionada
  static Future<String?> getFincaSeleccionada() async {
    final prefs = await SharedPreferences.getInstance();
    final farmId = prefs.getString(_keyFincaSeleccionada);
    return (farmId != null && farmId.isNotEmpty) ? farmId : null;
  }

  // Limpiar finca seleccionada
  static Future<void> clearFincaSeleccionada() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFincaSeleccionada);
  }

  static Future<String?> getUsuarioId() async {
    final usuario = await getUsuario();
    return usuario?.id;
  }

  static Future<void> setFincasDelUsuario(List<UsuarioFinca> relaciones) async {
    final prefs = await SharedPreferences.getInstance();
    final fincaIds =
        relaciones.map((r) => r.farmId).toSet().toList(); // Evita duplicados
    await prefs.setStringList('finca_ids', fincaIds);
    print('[SessionService] Guardando finca_ids: $fincaIds');
  }

  static Future<List<String>> getFincasDelUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('finca_ids') ?? [];
    print('[SessionService] Obteniendo finca_ids: $ids');
    return ids;
  }
}
