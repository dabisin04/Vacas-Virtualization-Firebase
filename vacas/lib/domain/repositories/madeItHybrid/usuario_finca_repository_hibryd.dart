import 'package:vacas/domain/entities/usuario_finca.dart';
import 'package:vacas/domain/repositories/usuario_finca_repository.dart';

class UsuarioFincaRepositoryHybrid implements UsuarioFincaRepository {
  final UsuarioFincaRepository localRepository;
  final UsuarioFincaRepository firebaseRepository;

  UsuarioFincaRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> asignarUsuarioAFinca(UsuarioFinca relacion) async {
    await Future.wait([
      localRepository.asignarUsuarioAFinca(relacion),
      firebaseRepository.asignarUsuarioAFinca(relacion),
    ]);
  }

  @override
  Future<List<String>> getFincaIdsByUsuario(String userId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getFincaIdsByUsuario(userId);
  }

  @override
  Future<List<String>> getUsuarioIdsByFinca(String farmId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getUsuarioIdsByFinca(farmId);
  }

  @override
  Future<void> eliminarRelacion(String id) async {
    await Future.wait([
      localRepository.eliminarRelacion(id),
      firebaseRepository.eliminarRelacion(id),
    ]);
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
