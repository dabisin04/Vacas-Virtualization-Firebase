import 'package:equatable/equatable.dart';
import '../../../domain/entities/produccion_leche.dart';

abstract class ProduccionLecheEvent extends Equatable {
  const ProduccionLecheEvent();
  @override
  List<Object?> get props => [];
}

class CargarProduccion extends ProduccionLecheEvent {
  final String animalId;
  const CargarProduccion(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class AgregarProduccion extends ProduccionLecheEvent {
  final ProduccionLeche produccion;
  const AgregarProduccion(this.produccion);

  @override
  List<Object?> get props => [produccion];
}

class ActualizarProduccion extends ProduccionLecheEvent {
  final ProduccionLeche produccion;
  const ActualizarProduccion(this.produccion);

  @override
  List<Object?> get props => [produccion];
}

class EliminarProduccion extends ProduccionLecheEvent {
  final String id;
  const EliminarProduccion(this.id);

  @override
  List<Object?> get props => [id];
}

class SincronizarProduccion extends ProduccionLecheEvent {}

class CargarProduccionGlobal extends ProduccionLecheEvent {}

class CargarProduccionPorFinca extends ProduccionLecheEvent {
  final String farmId;
  const CargarProduccionPorFinca(this.farmId);

  @override
  List<Object?> get props => [farmId];
}
