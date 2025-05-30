import 'package:equatable/equatable.dart';
import '../../../domain/entities/produccion_leche.dart';

abstract class ProduccionLecheState extends Equatable {
  const ProduccionLecheState();
  @override
  List<Object?> get props => [];
}

class ProduccionInicial extends ProduccionLecheState {}

class ProduccionCargando extends ProduccionLecheState {}

class ProduccionCargada extends ProduccionLecheState {
  final List<ProduccionLeche> lista;
  const ProduccionCargada(this.lista);

  @override
  List<Object?> get props => [lista];
}

class ProduccionError extends ProduccionLecheState {
  final String mensaje;
  const ProduccionError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
