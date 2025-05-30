import '../entities/chequeo_salud.dart';

abstract class ChequeoSaludRepository {
  Future<void> addChequeo(ChequeoSalud chequeo);
  Future<void> updateChequeo(ChequeoSalud chequeo);
  Future<void> deleteChequeo(String id);
  Future<List<ChequeoSalud>> getChequeosByAnimal(String animalId);
  Future<void> syncWithServer();
}
