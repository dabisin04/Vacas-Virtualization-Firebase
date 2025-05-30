import '../entities/produccion_leche.dart';

abstract class ProduccionLecheRepository {
  Future<void> addProduccion(ProduccionLeche produccion);
  Future<void> updateProduccion(ProduccionLeche produccion);
  Future<void> deleteProduccion(String id);
  Future<List<ProduccionLeche>> getProduccionByAnimal(String animalId);
  Future<List<ProduccionLeche>> getAllProduccion();
  Future<List<ProduccionLeche>> getProduccionByFarm(String farmId);
  Future<void> syncWithServer();
}
