import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/peso_repository.dart';
import 'peso_event.dart';
import 'peso_state.dart';

class PesoBloc extends Bloc<PesoEvent, PesoState> {
  final PesoRepository repository;

  PesoBloc(this.repository) : super(PesoInicial()) {
    on<CargarPesos>(_onCargarPesos);
    on<AgregarPeso>(_onAgregarPeso);
    on<ActualizarPeso>(_onActualizarPeso);
    on<EliminarPeso>(_onEliminarPeso);
    on<SincronizarPesos>(_onSincronizarPesos);
  }

  Future<void> _onCargarPesos(
      CargarPesos event, Emitter<PesoState> emit) async {
    emit(PesoCargando());
    try {
      final pesos = await repository.getPesosByAnimal(event.animalId);
      emit(PesosCargados(pesos));
    } catch (e) {
      emit(PesoError("Error al cargar pesos: $e"));
    }
  }

  Future<void> _onAgregarPeso(
      AgregarPeso event, Emitter<PesoState> emit) async {
    try {
      await repository.addPeso(event.peso);
      add(CargarPesos(event.peso.animalId));
    } catch (e) {
      emit(PesoError("Error al agregar peso: $e"));
    }
  }

  Future<void> _onActualizarPeso(
      ActualizarPeso event, Emitter<PesoState> emit) async {
    try {
      await repository.updatePeso(event.peso);
      add(CargarPesos(event.peso.animalId));
    } catch (e) {
      emit(PesoError("Error al actualizar peso: $e"));
    }
  }

  Future<void> _onEliminarPeso(
      EliminarPeso event, Emitter<PesoState> emit) async {
    try {
      await repository.deletePeso(event.id);
    } catch (e) {
      emit(PesoError("Error al eliminar peso: $e"));
    }
  }

  Future<void> _onSincronizarPesos(
      SincronizarPesos event, Emitter<PesoState> emit) async {
    try {
      await repository.syncWithServer();
    } catch (e) {
      emit(PesoError("Error al sincronizar pesos: $e"));
    }
  }
}
