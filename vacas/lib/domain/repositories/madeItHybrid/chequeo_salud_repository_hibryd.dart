import 'package:vacas/domain/entities/chequeo_salud.dart';
import 'package:vacas/domain/repositories/chequeo_salud_repository.dart';

class ChequeoSaludRepositoryHybrid implements ChequeoSaludRepository {
  final ChequeoSaludRepository localRepository;
  final ChequeoSaludRepository firebaseRepository;

  ChequeoSaludRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> addChequeo(ChequeoSalud chequeo) async {
    await Future.wait([
      localRepository.addChequeo(chequeo),
      firebaseRepository.addChequeo(chequeo),
    ]);
  }

  @override
  Future<void> updateChequeo(ChequeoSalud chequeo) async {
    await Future.wait([
      localRepository.updateChequeo(chequeo),
      firebaseRepository.updateChequeo(chequeo),
    ]);
  }

  @override
  Future<void> deleteChequeo(String id) async {
    await Future.wait([
      localRepository.deleteChequeo(id),
      firebaseRepository.deleteChequeo(id),
    ]);
  }

  @override
  Future<List<ChequeoSalud>> getChequeosByAnimal(String animalId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getChequeosByAnimal(animalId);
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
