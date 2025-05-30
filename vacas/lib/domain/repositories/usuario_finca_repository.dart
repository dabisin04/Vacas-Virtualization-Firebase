import '../entities/usuario_finca.dart';

abstract class UsuarioFincaRepository {
  Future<void> asignarUsuarioAFinca(UsuarioFinca relacion);
  Future<List<String>> getFincaIdsByUsuario(String userId);
  Future<List<String>> getUsuarioIdsByFinca(String farmId);
  Future<void> eliminarRelacion(String id);
  Future<void> syncWithServer();
}
