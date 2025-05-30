import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../../domain/entities/animal.dart';

abstract class AnimalEvent extends Equatable {
  const AnimalEvent();
  @override
  List<Object?> get props => [];
}

class CargarAnimales extends AnimalEvent {
  final String farmId;
  const CargarAnimales(this.farmId);

  @override
  List<Object?> get props => [farmId];
}

class AgregarAnimal extends AnimalEvent {
  final Animal animal;
  const AgregarAnimal(this.animal);

  @override
  List<Object?> get props => [animal];
}

class ActualizarAnimal extends AnimalEvent {
  final Animal animal;
  const ActualizarAnimal(this.animal);

  @override
  List<Object?> get props => [animal];
}

class EliminarAnimal extends AnimalEvent {
  final String animalId;
  const EliminarAnimal(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class ActualizarFotoAnimal extends AnimalEvent {
  final File imagen;
  final String animalId;

  const ActualizarFotoAnimal(this.animalId, this.imagen);

  @override
  List<Object?> get props => [animalId, imagen];
}

class SincronizarAnimales extends AnimalEvent {}
