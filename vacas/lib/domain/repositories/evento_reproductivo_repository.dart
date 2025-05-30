import '../entities/evento_reproductivo.dart';

abstract class EventoReproductivoRepository {
  Future<void> addEvento(EventoReproductivo evento);
  Future<void> updateEvento(EventoReproductivo evento);
  Future<void> deleteEvento(String id);
  Future<List<EventoReproductivo>> getEventosByAnimal(String animalId);
  Future<List<EventoReproductivo>> getEventosByFarm(String farmId);
  Future<List<EventoReproductivo>> getAllEventos();
  Future<void> syncWithServer();
}
