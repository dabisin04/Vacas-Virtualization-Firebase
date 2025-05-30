import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UsuarioState extends Equatable {
  const UsuarioState();
  @override
  List<Object?> get props => [];
}

class UsuarioInicial extends UsuarioState {}

class UsuarioCargando extends UsuarioState {}

class UsuarioAutenticado extends UsuarioState {
  final Usuario usuario;
  const UsuarioAutenticado(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class UsuarioNoAutenticado extends UsuarioState {}

class UsuarioError extends UsuarioState {
  final String mensaje;
  const UsuarioError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
