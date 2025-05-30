import '../entities/tratamiento.dart';

abstract class TratamientoRepository {
  Future<void> addTratamiento(Tratamiento tratamiento);
  Future<void> updateTratamiento(Tratamiento tratamiento);
  Future<void> deleteTratamiento(String id);
  Future<List<Tratamiento>> getTratamientosByAnimal(String animalId);
  Future<void> syncWithServer();
}
