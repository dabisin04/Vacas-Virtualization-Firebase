import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UsuarioEvent extends Equatable {
  const UsuarioEvent();
  @override
  List<Object?> get props => [];
}

class LoginUsuario extends UsuarioEvent {
  final String email;
  final String password;
  const LoginUsuario(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LogoutUsuario extends UsuarioEvent {}

class CargarSesionUsuario extends UsuarioEvent {}

class CrearUsuario extends UsuarioEvent {
  final Usuario usuario;
  const CrearUsuario(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class ActualizarUsuario extends UsuarioEvent {
  final Usuario usuario;
  const ActualizarUsuario(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class EliminarUsuario extends UsuarioEvent {
  final String id;
  const EliminarUsuario(this.id);

  @override
  List<Object?> get props => [id];
}
