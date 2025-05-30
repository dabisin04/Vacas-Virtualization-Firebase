import 'package:equatable/equatable.dart';
import '../../../domain/entities/chequeo_salud.dart';

abstract class ChequeoSaludEvent extends Equatable {
  const ChequeoSaludEvent();
  @override
  List<Object?> get props => [];
}

class CargarChequeos extends ChequeoSaludEvent {
  final String animalId;
  const CargarChequeos(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class AgregarChequeo extends ChequeoSaludEvent {
  final ChequeoSalud chequeo;
  const AgregarChequeo(this.chequeo);

  @override
  List<Object?> get props => [chequeo];
}

class ActualizarChequeo extends ChequeoSaludEvent {
  final ChequeoSalud chequeo;
  const ActualizarChequeo(this.chequeo);

  @override
  List<Object?> get props => [chequeo];
}

class EliminarChequeo extends ChequeoSaludEvent {
  final String id;
  const EliminarChequeo(this.id);

  @override
  List<Object?> get props => [id];
}

class SincronizarChequeos extends ChequeoSaludEvent {}
