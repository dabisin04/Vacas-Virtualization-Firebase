import 'package:equatable/equatable.dart';
import '../../../domain/entities/vacuna.dart';

abstract class VacunaEvent extends Equatable {
  const VacunaEvent();
  @override
  List<Object?> get props => [];
}

class CargarVacunas extends VacunaEvent {
  final String animalId;
  const CargarVacunas(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class AgregarVacuna extends VacunaEvent {
  final Vacuna vacuna;
  const AgregarVacuna(this.vacuna);

  @override
  List<Object?> get props => [vacuna];
}

class ActualizarVacuna extends VacunaEvent {
  final Vacuna vacuna;
  const ActualizarVacuna(this.vacuna);

  @override
  List<Object?> get props => [vacuna];
}

class EliminarVacuna extends VacunaEvent {
  final String id;
  const EliminarVacuna(this.id);

  @override
  List<Object?> get props => [id];
}

class SincronizarVacunas extends VacunaEvent {}
