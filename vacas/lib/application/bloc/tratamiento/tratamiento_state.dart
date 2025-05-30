import 'package:equatable/equatable.dart';
import '../../../domain/entities/tratamiento.dart';

abstract class TratamientoState extends Equatable {
  const TratamientoState();
  @override
  List<Object?> get props => [];
}

class TratamientoInicial extends TratamientoState {}

class TratamientoCargando extends TratamientoState {}

class TratamientosCargados extends TratamientoState {
  final List<Tratamiento> tratamientos;
  const TratamientosCargados(this.tratamientos);

  @override
  List<Object?> get props => [tratamientos];
}

class TratamientoError extends TratamientoState {
  final String mensaje;
  const TratamientoError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
