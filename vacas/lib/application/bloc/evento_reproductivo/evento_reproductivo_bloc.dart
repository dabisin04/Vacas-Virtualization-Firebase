import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/evento_reproductivo_repository.dart';
import 'evento_reproductivo_event.dart';
import 'evento_reproductivo_state.dart';

class EventoReproductivoBloc
    extends Bloc<EventoReproductivoEvent, EventoReproductivoState> {
  final EventoReproductivoRepository repository;

  EventoReproductivoBloc(this.repository) : super(EventoInicial()) {
    on<CargarEventos>(_onCargarEventos);
    on<AgregarEvento>(_onAgregarEvento);
    on<ActualizarEvento>(_onActualizarEvento);
    on<EliminarEvento>(_onEliminarEvento);
    on<SincronizarEventos>(_onSincronizarEventos);
    on<CargarEventosGlobal>(_onCargarEventosGlobal);
    on<CargarEventosPorFinca>(_onCargarEventosPorFinca);
  }

  Future<void> _onCargarEventos(
      CargarEventos event, Emitter<EventoReproductivoState> emit) async {
    emit(EventoCargando());
    try {
      final eventos = await repository.getEventosByAnimal(event.animalId);
      emit(EventosCargados(eventos));
    } catch (e) {
      emit(EventoError("Error al cargar eventos: $e"));
    }
  }

  Future<void> _onCargarEventosGlobal(
      CargarEventosGlobal event, Emitter<EventoReproductivoState> emit) async {
    emit(EventoCargando());
    try {
      final lista = await repository.getAllEventos();
      emit(EventosGlobalCargados(lista));
    } catch (e) {
      emit(EventoError('Error al cargar resumen global: $e'));
    }
  }

  Future<void> _onCargarEventosPorFinca(CargarEventosPorFinca event,
      Emitter<EventoReproductivoState> emit) async {
    emit(EventoCargando());
    try {
      final lista = await repository.getEventosByFarm(event.farmId);
      emit(EventosPorFincaCargados(event.farmId, lista));
    } catch (e) {
      emit(EventoError('Error al cargar eventos de la finca: $e'));
    }
  }

  Future<void> _onAgregarEvento(
      AgregarEvento event, Emitter<EventoReproductivoState> emit) async {
    try {
      await repository.addEvento(event.evento);
      add(CargarEventos(event.evento.animalId));
    } catch (e) {
      emit(EventoError("Error al agregar evento: $e"));
    }
  }

  Future<void> _onActualizarEvento(
      ActualizarEvento event, Emitter<EventoReproductivoState> emit) async {
    try {
      await repository.updateEvento(event.evento);
      add(CargarEventos(event.evento.animalId));
    } catch (e) {
      emit(EventoError("Error al actualizar evento: $e"));
    }
  }

  Future<void> _onEliminarEvento(
      EliminarEvento event, Emitter<EventoReproductivoState> emit) async {
    try {
      await repository.deleteEvento(event.id);
    } catch (e) {
      emit(EventoError("Error al eliminar evento: $e"));
    }
  }

  Future<void> _onSincronizarEventos(
      SincronizarEventos event, Emitter<EventoReproductivoState> emit) async {
    try {
      await repository.syncWithServer();
    } catch (e) {
      emit(EventoError("Error al sincronizar eventos: $e"));
    }
  }
}
