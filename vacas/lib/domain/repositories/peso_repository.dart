import '../entities/peso.dart';

abstract class PesoRepository {
  Future<void> addPeso(Peso peso);
  Future<void> updatePeso(Peso peso);
  Future<void> deletePeso(String id);
  Future<List<Peso>> getPesosByAnimal(String animalId);
  Future<void> syncWithServer();
}
