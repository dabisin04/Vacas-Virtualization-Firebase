import 'package:equatable/equatable.dart';
import '../../../domain/entities/usuario_finca.dart';

abstract class UsuarioFincaEvent extends Equatable {
  const UsuarioFincaEvent();

  @override
  List<Object?> get props => [];
}

class AsignarUsuarioAFinca extends UsuarioFincaEvent {
  final UsuarioFinca relacion;
  const AsignarUsuarioAFinca(this.relacion);

  @override
  List<Object?> get props => [relacion];
}

class CargarFincasDelUsuario extends UsuarioFincaEvent {
  final String userId;
  const CargarFincasDelUsuario(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CargarUsuariosDeFinca extends UsuarioFincaEvent {
  final String farmId;
  const CargarUsuariosDeFinca(this.farmId);

  @override
  List<Object?> get props => [farmId];
}

class EliminarRelacionUsuarioFinca extends UsuarioFincaEvent {
  final String relacionId;
  const EliminarRelacionUsuarioFinca(this.relacionId);

  @override
  List<Object?> get props => [relacionId];
}

class SincronizarRelacionesUsuarioFinca extends UsuarioFincaEvent {}
