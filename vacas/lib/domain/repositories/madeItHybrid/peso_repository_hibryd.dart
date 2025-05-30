import 'package:vacas/domain/entities/peso.dart';
import 'package:vacas/domain/repositories/peso_repository.dart';

class PesoRepositoryHybrid implements PesoRepository {
  final PesoRepository localRepository;
  final PesoRepository firebaseRepository;

  PesoRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> addPeso(Peso peso) async {
    await Future.wait([
      localRepository.addPeso(peso),
      firebaseRepository.addPeso(peso),
    ]);
  }

  @override
  Future<void> updatePeso(Peso peso) async {
    await Future.wait([
      localRepository.updatePeso(peso),
      firebaseRepository.updatePeso(peso),
    ]);
  }

  @override
  Future<void> deletePeso(String id) async {
    await Future.wait([
      localRepository.deletePeso(id),
      firebaseRepository.deletePeso(id),
    ]);
  }

  @override
  Future<List<Peso>> getPesosByAnimal(String animalId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getPesosByAnimal(animalId);
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
