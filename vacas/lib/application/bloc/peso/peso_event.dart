import 'package:equatable/equatable.dart';
import '../../../domain/entities/peso.dart';

abstract class PesoEvent extends Equatable {
  const PesoEvent();
  @override
  List<Object?> get props => [];
}

class CargarPesos extends PesoEvent {
  final String animalId;
  const CargarPesos(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class AgregarPeso extends PesoEvent {
  final Peso peso;
  const AgregarPeso(this.peso);

  @override
  List<Object?> get props => [peso];
}

class ActualizarPeso extends PesoEvent {
  final Peso peso;
  const ActualizarPeso(this.peso);

  @override
  List<Object?> get props => [peso];
}

class EliminarPeso extends PesoEvent {
  final String id;
  const EliminarPeso(this.id);

  @override
  List<Object?> get props => [id];
}

class SincronizarPesos extends PesoEvent {}
