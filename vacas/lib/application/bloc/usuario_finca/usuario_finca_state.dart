import 'package:equatable/equatable.dart';

abstract class UsuarioFincaState extends Equatable {
  const UsuarioFincaState();

  @override
  List<Object?> get props => [];
}

class UsuarioFincaInicial extends UsuarioFincaState {}

class UsuarioFincaCargando extends UsuarioFincaState {}

class FincasDelUsuarioCargadas extends UsuarioFincaState {
  final List<String> fincaIds;
  const FincasDelUsuarioCargadas(this.fincaIds);

  @override
  List<Object?> get props => [fincaIds];
}

class UsuariosDeFincaCargados extends UsuarioFincaState {
  final List<String> usuarioIds;
  const UsuariosDeFincaCargados(this.usuarioIds);

  @override
  List<Object?> get props => [usuarioIds];
}

class UsuarioFincaError extends UsuarioFincaState {
  final String mensaje;
  const UsuarioFincaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
