import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/tratamiento_repository.dart';
import 'tratamiento_event.dart';
import 'tratamiento_state.dart';

class TratamientoBloc extends Bloc<TratamientoEvent, TratamientoState> {
  final TratamientoRepository repository;

  TratamientoBloc(this.repository) : super(TratamientoInicial()) {
    on<CargarTratamientos>(_onCargarTratamientos);
    on<AgregarTratamiento>(_onAgregarTratamiento);
    on<ActualizarTratamiento>(_onActualizarTratamiento);
    on<EliminarTratamiento>(_onEliminarTratamiento);
    on<SincronizarTratamientos>(_onSincronizarTratamientos);
  }

  Future<void> _onCargarTratamientos(
      CargarTratamientos event, Emitter<TratamientoState> emit) async {
    emit(TratamientoCargando());
    try {
      final lista = await repository.getTratamientosByAnimal(event.animalId);
      emit(TratamientosCargados(lista));
    } catch (e) {
      emit(TratamientoError("Error al cargar tratamientos: $e"));
    }
  }

  Future<void> _onAgregarTratamiento(
      AgregarTratamiento event, Emitter<TratamientoState> emit) async {
    try {
      await repository.addTratamiento(event.tratamiento);
      add(CargarTratamientos(event.tratamiento.animalId));
    } catch (e) {
      emit(TratamientoError("Error al agregar tratamiento: $e"));
    }
  }

  Future<void> _onActualizarTratamiento(
      ActualizarTratamiento event, Emitter<TratamientoState> emit) async {
    try {
      await repository.updateTratamiento(event.tratamiento);
      add(CargarTratamientos(event.tratamiento.animalId));
    } catch (e) {
      emit(TratamientoError("Error al actualizar tratamiento: $e"));
    }
  }

  Future<void> _onEliminarTratamiento(
      EliminarTratamiento event, Emitter<TratamientoState> emit) async {
    try {
      await repository.deleteTratamiento(event.id);
    } catch (e) {
      emit(TratamientoError("Error al eliminar tratamiento: $e"));
    }
  }

  Future<void> _onSincronizarTratamientos(
      SincronizarTratamientos event, Emitter<TratamientoState> emit) async {
    try {
      await repository.syncWithServer();
    } catch (e) {
      emit(TratamientoError("Error al sincronizar tratamientos: $e"));
    }
  }
}
