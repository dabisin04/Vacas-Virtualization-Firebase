import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../../domain/repositories/user_repository.dart';

class UsuarioBloc extends Bloc<UsuarioEvent, UsuarioState> {
  final UserRepository userRepository;

  UsuarioBloc(this.userRepository) : super(UsuarioInicial()) {
    on<LoginUsuario>(_onLogin);
    on<LogoutUsuario>(_onLogout);
    on<CargarSesionUsuario>(_onCargarSesion);
    on<CrearUsuario>(_onCrear);
    on<ActualizarUsuario>(_onActualizar);
    on<EliminarUsuario>(_onEliminar);
  }

  // ─────────────────────────── Handlers ───────────────────────────

  Future<void> _onLogin(LoginUsuario event, Emitter<UsuarioState> emit) async {
    print('[UsuarioBloc] _onLogin → email=${event.email} password=${event.password}');
    emit(UsuarioCargando());

    try {
      await userRepository.login(event.email, event.password);
      final usuario = await userRepository.getCurrentSession();

      if (usuario != null) {
        print('[UsuarioBloc] login OK → ${usuario.id}');
        emit(UsuarioAutenticado(usuario));
      } else {
        emit(const UsuarioError("Error al cargar usuario tras login."));
      }
    } catch (e, st) {
      print('[UsuarioBloc] login ERROR → $e\n$st');
      emit(UsuarioError(e.toString()));
    }
  }

  Future<void> _onLogout(
      LogoutUsuario event, Emitter<UsuarioState> emit) async {
    print('[UsuarioBloc] _onLogout');
    await userRepository.logout();
    emit(UsuarioNoAutenticado());
  }

  Future<void> _onCargarSesion(
      CargarSesionUsuario event, Emitter<UsuarioState> emit) async {
    print('[UsuarioBloc] _onCargarSesion');
    final usuario = await userRepository.getCurrentSession();
    emit(
        usuario != null ? UsuarioAutenticado(usuario) : UsuarioNoAutenticado());
  }

  Future<void> _onCrear(CrearUsuario event, Emitter<UsuarioState> emit) async {
    print('[UsuarioBloc] _onCrear → ${event.usuario.toJson()}');
    emit(UsuarioCargando());

    try {
      await userRepository.createUser(event.usuario);
      emit(UsuarioAutenticado(event.usuario));
      print('[UsuarioBloc] usuario creado y autenticado');
    } catch (e, st) {
      print('[UsuarioBloc] create ERROR → $e\n$st');
      emit(UsuarioError("No se pudo crear el usuario: $e"));
    }
  }

  Future<void> _onActualizar(
      ActualizarUsuario event, Emitter<UsuarioState> emit) async {
    print('[UsuarioBloc] _onActualizar → id=${event.usuario.id}');
    try {
      await userRepository.updateUser(event.usuario);
    } catch (e, st) {
      print('[UsuarioBloc] update ERROR → $e\n$st');
      emit(UsuarioError("No se pudo actualizar el usuario: $e"));
    }
  }

  Future<void> _onEliminar(
      EliminarUsuario event, Emitter<UsuarioState> emit) async {
    print('[UsuarioBloc] _onEliminar → id=${event.id}');
    try {
      await userRepository.deleteUser(event.id);
    } catch (e, st) {
      print('[UsuarioBloc] delete ERROR → $e\n$st');
      emit(UsuarioError("No se pudo eliminar el usuario: $e"));
    }
  }
}
