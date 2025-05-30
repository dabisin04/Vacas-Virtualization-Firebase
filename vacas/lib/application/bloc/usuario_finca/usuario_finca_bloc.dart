import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/domain/entities/usuario_finca.dart';
import 'usuario_finca_event.dart';
import 'usuario_finca_state.dart';
import '../../../domain/repositories/usuario_finca_repository.dart';

class UsuarioFincaBloc extends Bloc<UsuarioFincaEvent, UsuarioFincaState> {
  final UsuarioFincaRepository repository;

  UsuarioFincaBloc(this.repository) : super(UsuarioFincaInicial()) {
    on<AsignarUsuarioAFinca>(_onAsignar);
    on<CargarFincasDelUsuario>(_onCargarFincas);
    on<CargarUsuariosDeFinca>(_onCargarUsuarios);
    on<EliminarRelacionUsuarioFinca>(_onEliminarRelacion);
    on<SincronizarRelacionesUsuarioFinca>(_onSincronizar);
  }

  Future<void> _onAsignar(
      AsignarUsuarioAFinca event, Emitter<UsuarioFincaState> emit) async {
    try {
      await repository.asignarUsuarioAFinca(event.relacion);
      add(CargarFincasDelUsuario(event.relacion.userId));
    } catch (e) {
      emit(UsuarioFincaError("Error al asignar usuario a finca: $e"));
    }
  }

  Future<void> _onCargarFincas(
      CargarFincasDelUsuario event, Emitter<UsuarioFincaState> emit) async {
    emit(UsuarioFincaCargando());
    try {
      final fincaIds = await repository.getFincaIdsByUsuario(event.userId);

      final relaciones = fincaIds
          .map((fincaId) => UsuarioFinca(
                id: 'rel-${event.userId}-$fincaId',
                userId: event.userId,
                farmId: fincaId,
              ))
          .toList();
      await SessionService.setFincasDelUsuario(relaciones);

      emit(FincasDelUsuarioCargadas(fincaIds));
    } catch (e) {
      emit(UsuarioFincaError("Error al cargar fincas del usuario: $e"));
    }
  }

  Future<void> _onCargarUsuarios(
      CargarUsuariosDeFinca event, Emitter<UsuarioFincaState> emit) async {
    emit(UsuarioFincaCargando());
    try {
      final usuarioIds = await repository.getUsuarioIdsByFinca(event.farmId);
      emit(UsuariosDeFincaCargados(usuarioIds));
    } catch (e) {
      emit(UsuarioFincaError("Error al cargar usuarios de finca: $e"));
    }
  }

  Future<void> _onEliminarRelacion(EliminarRelacionUsuarioFinca event,
      Emitter<UsuarioFincaState> emit) async {
    try {
      await repository.eliminarRelacion(event.relacionId);
    } catch (e) {
      emit(UsuarioFincaError("Error al eliminar relación: $e"));
    }
  }

  Future<void> _onSincronizar(SincronizarRelacionesUsuarioFinca event,
      Emitter<UsuarioFincaState> emit) async {
    // Implementar lógica de sincronización cuando se use backend
  }
}
