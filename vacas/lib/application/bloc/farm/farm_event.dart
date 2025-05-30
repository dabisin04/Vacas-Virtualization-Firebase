import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../../domain/entities/farm.dart';

abstract class FarmEvent extends Equatable {
  const FarmEvent();
  @override
  List<Object?> get props => [];
}

class CargarFincasDelUsuario extends FarmEvent {
  final String userId;
  const CargarFincasDelUsuario(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CrearFinca extends FarmEvent {
  final Farm farm;
  const CrearFinca(this.farm);

  @override
  List<Object?> get props => [farm];
}

class ActualizarFinca extends FarmEvent {
  final Farm farm;
  const ActualizarFinca(this.farm);

  @override
  List<Object?> get props => [farm];
}

class ActualizarFotoFinca extends FarmEvent {
  final Farm finca;
  final File imagen;

  const ActualizarFotoFinca(this.finca, this.imagen);

  @override
  List<Object?> get props => [finca, imagen];
}

class CargarFincaPorId extends FarmEvent {
  final String farmId;
  const CargarFincaPorId(this.farmId);

  @override
  List<Object?> get props => [farmId];
}

class EliminarFinca extends FarmEvent {
  final String farmId;
  final String userId;

  const EliminarFinca(this.farmId, this.userId);

  @override
  List<Object?> get props => [farmId, userId];
}
