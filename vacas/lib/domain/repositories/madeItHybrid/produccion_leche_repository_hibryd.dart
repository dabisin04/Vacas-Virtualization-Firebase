import 'package:vacas/domain/entities/produccion_leche.dart';
import 'package:vacas/domain/repositories/produccion_leche_repository.dart';

class ProduccionLecheRepositoryHybrid implements ProduccionLecheRepository {
  final ProduccionLecheRepository localRepository;
  final ProduccionLecheRepository firebaseRepository;

  ProduccionLecheRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> addProduccion(ProduccionLeche produccion) async {
    await Future.wait([
      localRepository.addProduccion(produccion),
      firebaseRepository.addProduccion(produccion),
    ]);
  }

  @override
  Future<void> updateProduccion(ProduccionLeche produccion) async {
    await Future.wait([
      localRepository.updateProduccion(produccion),
      firebaseRepository.updateProduccion(produccion),
    ]);
  }

  @override
  Future<void> deleteProduccion(String id) async {
    await Future.wait([
      localRepository.deleteProduccion(id),
      firebaseRepository.deleteProduccion(id),
    ]);
  }

  @override
  Future<List<ProduccionLeche>> getProduccionByAnimal(String animalId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getProduccionByAnimal(animalId);
  }

  @override
  Future<List<ProduccionLeche>> getAllProduccion() async {
    return await localRepository.getAllProduccion();
  }

  @override
  Future<List<ProduccionLeche>> getProduccionByFarm(String farmId) async {
    return await localRepository.getProduccionByFarm(farmId);
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
