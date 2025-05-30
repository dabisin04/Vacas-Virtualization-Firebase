import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/vacuna_repository.dart';
import 'vacuna_event.dart';
import 'vacuna_state.dart';

class VacunaBloc extends Bloc<VacunaEvent, VacunaState> {
  final VacunaRepository vacunaRepository;

  VacunaBloc(this.vacunaRepository) : super(VacunaInicial()) {
    on<CargarVacunas>(_onCargarVacunas);
    on<AgregarVacuna>(_onAgregarVacuna);
    on<ActualizarVacuna>(_onActualizarVacuna);
    on<EliminarVacuna>(_onEliminarVacuna);
    on<SincronizarVacunas>(_onSincronizarVacunas);
  }

  Future<void> _onCargarVacunas(
      CargarVacunas event, Emitter<VacunaState> emit) async {
    emit(VacunaCargando());
    try {
      final vacunas = await vacunaRepository.getVacunasByAnimal(event.animalId);
      emit(VacunasCargadas(vacunas));
    } catch (e) {
      emit(VacunaError("Error al cargar vacunas: $e"));
    }
  }

  Future<void> _onAgregarVacuna(
      AgregarVacuna event, Emitter<VacunaState> emit) async {
    try {
      await vacunaRepository.addVacuna(event.vacuna);
      add(CargarVacunas(event.vacuna.animalId));
    } catch (e) {
      emit(VacunaError("Error al agregar vacuna: $e"));
    }
  }

  Future<void> _onActualizarVacuna(
      ActualizarVacuna event, Emitter<VacunaState> emit) async {
    try {
      await vacunaRepository.updateVacuna(event.vacuna);
      add(CargarVacunas(event.vacuna.animalId));
    } catch (e) {
      emit(VacunaError("Error al actualizar vacuna: $e"));
    }
  }

  Future<void> _onEliminarVacuna(
      EliminarVacuna event, Emitter<VacunaState> emit) async {
    try {
      await vacunaRepository.deleteVacuna(event.id);
      // No se recarga automáticamente porque no tenemos el animalId aquí
    } catch (e) {
      emit(VacunaError("Error al eliminar vacuna: $e"));
    }
  }

  Future<void> _onSincronizarVacunas(
      SincronizarVacunas event, Emitter<VacunaState> emit) async {
    try {
      await vacunaRepository.syncWithServer();
    } catch (e) {
      emit(VacunaError("Error al sincronizar vacunas: $e"));
    }
  }
}
