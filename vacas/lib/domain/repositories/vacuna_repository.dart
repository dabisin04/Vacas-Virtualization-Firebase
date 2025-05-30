import '../entities/vacuna.dart';

abstract class VacunaRepository {
  Future<void> addVacuna(Vacuna vacuna);
  Future<void> updateVacuna(Vacuna vacuna);
  Future<void> deleteVacuna(String id);
  Future<List<Vacuna>> getVacunasByAnimal(String animalId);
  Future<void> syncWithServer();
}
