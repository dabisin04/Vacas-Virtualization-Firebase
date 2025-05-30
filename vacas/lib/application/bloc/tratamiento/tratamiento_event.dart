import 'package:equatable/equatable.dart';
import '../../../domain/entities/tratamiento.dart';

abstract class TratamientoEvent extends Equatable {
  const TratamientoEvent();
  @override
  List<Object?> get props => [];
}

class CargarTratamientos extends TratamientoEvent {
  final String animalId;
  const CargarTratamientos(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class AgregarTratamiento extends TratamientoEvent {
  final Tratamiento tratamiento;
  const AgregarTratamiento(this.tratamiento);

  @override
  List<Object?> get props => [tratamiento];
}

class ActualizarTratamiento extends TratamientoEvent {
  final Tratamiento tratamiento;
  const ActualizarTratamiento(this.tratamiento);

  @override
  List<Object?> get props => [tratamiento];
}

class EliminarTratamiento extends TratamientoEvent {
  final String id;
  const EliminarTratamiento(this.id);

  @override
  List<Object?> get props => [id];
}

class SincronizarTratamientos extends TratamientoEvent {}
