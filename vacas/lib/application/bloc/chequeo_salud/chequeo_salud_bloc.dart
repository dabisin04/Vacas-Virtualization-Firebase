import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/chequeo_salud_repository.dart';
import 'chequeo_salud_event.dart';
import 'chequeo_salud_state.dart';

class ChequeoSaludBloc extends Bloc<ChequeoSaludEvent, ChequeoSaludState> {
  final ChequeoSaludRepository repository;

  ChequeoSaludBloc(this.repository) : super(ChequeoInicial()) {
    on<CargarChequeos>(_onCargarChequeos);
    on<AgregarChequeo>(_onAgregarChequeo);
    on<ActualizarChequeo>(_onActualizarChequeo);
    on<EliminarChequeo>(_onEliminarChequeo);
    on<SincronizarChequeos>(_onSincronizarChequeos);
  }

  Future<void> _onCargarChequeos(
      CargarChequeos event, Emitter<ChequeoSaludState> emit) async {
    emit(ChequeoCargando());
    try {
      final lista = await repository.getChequeosByAnimal(event.animalId);
      emit(ChequeosCargados(lista));
    } catch (e) {
      emit(ChequeoError("Error al cargar chequeos: $e"));
    }
  }

  Future<void> _onAgregarChequeo(
      AgregarChequeo event, Emitter<ChequeoSaludState> emit) async {
    try {
      await repository.addChequeo(event.chequeo);
      add(CargarChequeos(event.chequeo.animalId));
    } catch (e) {
      emit(ChequeoError("Error al agregar chequeo: $e"));
    }
  }

  Future<void> _onActualizarChequeo(
      ActualizarChequeo event, Emitter<ChequeoSaludState> emit) async {
    try {
      await repository.updateChequeo(event.chequeo);
      add(CargarChequeos(event.chequeo.animalId));
    } catch (e) {
      emit(ChequeoError("Error al actualizar chequeo: $e"));
    }
  }

  Future<void> _onEliminarChequeo(
      EliminarChequeo event, Emitter<ChequeoSaludState> emit) async {
    try {
      await repository.deleteChequeo(event.id);
    } catch (e) {
      emit(ChequeoError("Error al eliminar chequeo: $e"));
    }
  }

  Future<void> _onSincronizarChequeos(
      SincronizarChequeos event, Emitter<ChequeoSaludState> emit) async {
    try {
      await repository.syncWithServer();
    } catch (e) {
      emit(ChequeoError("Error al sincronizar chequeos: $e"));
    }
  }
}
