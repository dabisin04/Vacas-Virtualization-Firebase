import 'package:vacas/domain/entities/tratamiento.dart';
import 'package:vacas/domain/repositories/tratamiento_repository.dart';

class TratamientoRepositoryHybrid implements TratamientoRepository {
  final TratamientoRepository localRepository;
  final TratamientoRepository firebaseRepository;

  TratamientoRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> addTratamiento(Tratamiento tratamiento) async {
    await Future.wait([
      localRepository.addTratamiento(tratamiento),
      firebaseRepository.addTratamiento(tratamiento),
    ]);
  }

  @override
  Future<void> updateTratamiento(Tratamiento tratamiento) async {
    await Future.wait([
      localRepository.updateTratamiento(tratamiento),
      firebaseRepository.updateTratamiento(tratamiento),
    ]);
  }

  @override
  Future<void> deleteTratamiento(String id) async {
    await Future.wait([
      localRepository.deleteTratamiento(id),
      firebaseRepository.deleteTratamiento(id),
    ]);
  }

  @override
  Future<List<Tratamiento>> getTratamientosByAnimal(String animalId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getTratamientosByAnimal(animalId);
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
