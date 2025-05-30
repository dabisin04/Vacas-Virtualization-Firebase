import 'package:equatable/equatable.dart';
import '../../../domain/entities/farm.dart';

abstract class FarmState extends Equatable {
  const FarmState();
  @override
  List<Object?> get props => [];
}

class FarmInicial extends FarmState {}

class FarmCargando extends FarmState {}

class FincasCargadas extends FarmState {
  final List<Farm> fincas;
  const FincasCargadas(this.fincas);

  @override
  List<Object?> get props => [fincas];
}

class FincaCargada extends FarmState {
  final Farm finca;
  const FincaCargada(this.finca);

  @override
  List<Object?> get props => [finca];
}

class FarmError extends FarmState {
  final String mensaje;
  const FarmError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

class FincaEliminada extends FarmState {
  final String farmId;
  const FincaEliminada(this.farmId);

  @override
  List<Object?> get props => [farmId];
}
