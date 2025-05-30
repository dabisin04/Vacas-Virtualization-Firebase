import 'package:equatable/equatable.dart';
import '../../../domain/entities/peso.dart';

abstract class PesoState extends Equatable {
  const PesoState();
  @override
  List<Object?> get props => [];
}

class PesoInicial extends PesoState {}

class PesoCargando extends PesoState {}

class PesosCargados extends PesoState {
  final List<Peso> pesos;
  const PesosCargados(this.pesos);

  @override
  List<Object?> get props => [pesos];
}

class PesoError extends PesoState {
  final String mensaje;
  const PesoError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
