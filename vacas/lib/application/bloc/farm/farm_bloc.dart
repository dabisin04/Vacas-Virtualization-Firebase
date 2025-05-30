import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/core/services/session_service.dart';
import '../../../domain/repositories/farm_repository.dart';
import 'farm_event.dart';
import 'farm_state.dart';

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  final FarmRepository repository;

  FarmBloc(this.repository) : super(FarmInicial()) {
    on<CargarFincasDelUsuario>(_onCargarFincas);
    on<CrearFinca>(_onCrearFinca);
    on<ActualizarFinca>(_onActualizarFinca);
    on<CargarFincaPorId>(_onCargarFincaPorId);
    on<EliminarFinca>(_onEliminarFinca);
    on<ActualizarFotoFinca>(_onActualizarFotoFinca);
  }

  Future<void> _onCargarFincas(
      CargarFincasDelUsuario event, Emitter<FarmState> emit) async {
    emit(FarmCargando());
    try {
      final fincas = await repository.getFarmsByUser(event.userId);
      emit(FincasCargadas(fincas));
    } catch (e) {
      emit(FarmError("Error al cargar fincas: $e"));
    }
  }

  Future<void> _onCrearFinca(CrearFinca event, Emitter<FarmState> emit) async {
    try {
      await repository.createFarm(event.farm);
      add(CargarFincasDelUsuario(event.farm.propietarioId));
    } catch (e) {
      emit(FarmError("Error al crear finca: $e"));
    }
  }

  Future<void> _onActualizarFinca(
      ActualizarFinca event, Emitter<FarmState> emit) async {
    try {
      await repository.updateFarm(event.farm);
      add(CargarFincasDelUsuario(event.farm.propietarioId));
    } catch (e) {
      emit(FarmError("Error al actualizar finca: $e"));
    }
  }

  Future<void> _onCargarFincaPorId(
      CargarFincaPorId event, Emitter<FarmState> emit) async {
    print('[FarmBloc] Solicitando finca con ID: ${event.farmId}');
    emit(FarmCargando());
    try {
      final finca = await repository.getFarmById(event.farmId);
      if (finca != null) {
        print('[FarmBloc] Finca encontrada: ${finca.nombre}');
        emit(FincaCargada(finca));
      } else {
        print('[FarmBloc] Finca no encontrada');
        emit(FarmError("Finca no encontrada"));
      }
    } catch (e) {
      print('[FarmBloc] Error al cargar finca: $e');
      emit(FarmError("Error al cargar finca: $e"));
    }
  }

  Future<void> _onEliminarFinca(
      EliminarFinca event, Emitter<FarmState> emit) async {
    emit(FarmCargando());
    try {
      await repository.deleteFarm(event.farmId);
      add(CargarFincasDelUsuario(event.userId));
      emit(FincaEliminada(event.farmId));
    } catch (e) {
      emit(FarmError("Error al eliminar finca: $e"));
    }
  }

  Future<void> _onActualizarFotoFinca(
      ActualizarFotoFinca event, Emitter<FarmState> emit) async {
    emit(FarmCargando());
    try {
      // 🔼 Subir imagen y obtener URL devuelta por el backend
      final url = await repository.uploadFarmImage(
        farmId: event.finca.id,
        imageFile: event.imagen,
      );

      if (url.isEmpty) {
        emit(FarmError(
            "Error al subir la imagen: respuesta vacía del servidor"));
        return;
      }

      // 🧩 Crear nueva instancia de finca con URL actualizada
      final fincaActualizada = event.finca.copyWith(fotoUrl: url);

      // 💾 Actualizar en base de datos local y sincronizar
      await repository.updateFarm(fincaActualizada);

      // 📦 Obtener usuario y cargar todas sus fincas nuevamente
      final usuario = await SessionService.getUsuario();
      final fincas = await repository.getFarmsByUser(usuario!.id);

      print('✅ Imagen subida y finca actualizada con nueva URL: $url');
      emit(FincasCargadas(fincas));
    } catch (e) {
      print('❌ Error al subir imagen o actualizar finca: $e');
      emit(FarmError("Error al actualizar la foto de la finca: $e"));
    }
  }
}
