import 'package:vacas/domain/entities/vacuna.dart';
import 'package:vacas/domain/repositories/vacuna_repository.dart';

class VacunaRepositoryHybrid implements VacunaRepository {
  final VacunaRepository localRepository;
  final VacunaRepository firebaseRepository;

  VacunaRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> addVacuna(Vacuna vacuna) async {
    await Future.wait([
      localRepository.addVacuna(vacuna),
      firebaseRepository.addVacuna(vacuna),
    ]);
  }

  @override
  Future<void> updateVacuna(Vacuna vacuna) async {
    await Future.wait([
      localRepository.updateVacuna(vacuna),
      firebaseRepository.updateVacuna(vacuna),
    ]);
  }

  @override
  Future<void> deleteVacuna(String id) async {
    await Future.wait([
      localRepository.deleteVacuna(id),
      firebaseRepository.deleteVacuna(id),
    ]);
  }

  @override
  Future<List<Vacuna>> getVacunasByAnimal(String animalId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getVacunasByAnimal(animalId);
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
