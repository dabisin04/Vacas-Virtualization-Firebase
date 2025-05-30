import 'package:vacas/domain/entities/evento_reproductivo.dart';
import 'package:vacas/domain/repositories/evento_reproductivo_repository.dart';

class EventoReproductivoRepositoryHybrid
    implements EventoReproductivoRepository {
  final EventoReproductivoRepository localRepository;
  final EventoReproductivoRepository firebaseRepository;

  EventoReproductivoRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> addEvento(EventoReproductivo evento) async {
    await Future.wait([
      localRepository.addEvento(evento),
      firebaseRepository.addEvento(evento),
    ]);
  }

  @override
  Future<void> updateEvento(EventoReproductivo evento) async {
    await Future.wait([
      localRepository.updateEvento(evento),
      firebaseRepository.updateEvento(evento),
    ]);
  }

  @override
  Future<void> deleteEvento(String id) async {
    await Future.wait([
      localRepository.deleteEvento(id),
      firebaseRepository.deleteEvento(id),
    ]);
  }

  @override
  Future<List<EventoReproductivo>> getEventosByAnimal(String animalId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getEventosByAnimal(animalId);
  }

  @override
  Future<List<EventoReproductivo>> getEventosByFarm(String farmId) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getEventosByFarm(farmId);
  }

  @override
  Future<List<EventoReproductivo>> getAllEventos() async {
    return await localRepository.getAllEventos();
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
