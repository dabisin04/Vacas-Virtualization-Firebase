import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/produccion_leche_repository.dart';
import 'produccion_leche_event.dart';
import 'produccion_leche_state.dart';

class ProduccionLecheBloc
    extends Bloc<ProduccionLecheEvent, ProduccionLecheState> {
  final ProduccionLecheRepository repository;

  ProduccionLecheBloc(this.repository) : super(ProduccionInicial()) {
    on<CargarProduccion>(_onCargarProduccion);
    on<AgregarProduccion>(_onAgregarProduccion);
    on<ActualizarProduccion>(_onActualizarProduccion);
    on<EliminarProduccion>(_onEliminarProduccion);
    on<SincronizarProduccion>(_onSincronizarProduccion);
    on<CargarProduccionGlobal>(_onCargarProduccionGlobal);
    on<CargarProduccionPorFinca>(_onCargarProduccionPorFinca);
  }

  Future<void> _onCargarProduccion(
      CargarProduccion event, Emitter<ProduccionLecheState> emit) async {
    emit(ProduccionCargando());
    try {
      final lista = await repository.getProduccionByAnimal(event.animalId);
      emit(ProduccionCargada(lista));
    } catch (e) {
      emit(ProduccionError("Error al cargar producción: $e"));
    }
  }

  Future<void> _onAgregarProduccion(
      AgregarProduccion event, Emitter<ProduccionLecheState> emit) async {
    try {
      await repository.addProduccion(event.produccion);
      add(CargarProduccion(event.produccion.animalId));
    } catch (e) {
      emit(ProduccionError("Error al agregar producción: $e"));
    }
  }

  Future<void> _onActualizarProduccion(
      ActualizarProduccion event, Emitter<ProduccionLecheState> emit) async {
    try {
      await repository.updateProduccion(event.produccion);
      add(CargarProduccion(event.produccion.animalId));
    } catch (e) {
      emit(ProduccionError("Error al actualizar producción: $e"));
    }
  }

  Future<void> _onEliminarProduccion(
      EliminarProduccion event, Emitter<ProduccionLecheState> emit) async {
    try {
      await repository.deleteProduccion(event.id);
      // No se recarga automáticamente sin el animalId
    } catch (e) {
      emit(ProduccionError("Error al eliminar producción: $e"));
    }
  }

  Future<void> _onSincronizarProduccion(
      SincronizarProduccion event, Emitter<ProduccionLecheState> emit) async {
    try {
      await repository.syncWithServer();
    } catch (e) {
      emit(ProduccionError("Error al sincronizar producción: $e"));
    }
  }

  Future<void> _onCargarProduccionGlobal(
      CargarProduccionGlobal event, Emitter<ProduccionLecheState> emit) async {
    emit(ProduccionCargando());
    try {
      final lista =
          await repository.getAllProduccion(); // Nuevo método en el repositorio
      emit(ProduccionCargada(lista));
    } catch (e) {
      emit(ProduccionError("Error al cargar el resumen: $e"));
    }
  }

  Future<void> _onCargarProduccionPorFinca(
    CargarProduccionPorFinca event,
    Emitter<ProduccionLecheState> emit,
  ) async {
    emit(ProduccionCargando());
    try {
      final lista = await repository.getProduccionByFarm(event.farmId);
      emit(ProduccionCargada(lista));
    } catch (e) {
      emit(ProduccionError("Error al cargar producción por finca: $e"));
    }
  }
}
