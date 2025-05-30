import 'package:equatable/equatable.dart';
import '../../../domain/entities/evento_reproductivo.dart';

abstract class EventoReproductivoEvent extends Equatable {
  const EventoReproductivoEvent();
  @override
  List<Object?> get props => [];
}

class CargarEventos extends EventoReproductivoEvent {
  final String animalId;
  const CargarEventos(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class CargarEventosPorFinca extends EventoReproductivoEvent {
  final String farmId;
  const CargarEventosPorFinca(this.farmId);
  @override
  List<Object?> get props => [farmId];
}

class CargarEventosGlobal extends EventoReproductivoEvent {
  const CargarEventosGlobal();
}

class AgregarEvento extends EventoReproductivoEvent {
  final EventoReproductivo evento;
  const AgregarEvento(this.evento);

  @override
  List<Object?> get props => [evento];
}

class ActualizarEvento extends EventoReproductivoEvent {
  final EventoReproductivo evento;
  const ActualizarEvento(this.evento);

  @override
  List<Object?> get props => [evento];
}

class EliminarEvento extends EventoReproductivoEvent {
  final String id;
  const EliminarEvento(this.id);

  @override
  List<Object?> get props => [id];
}

class SincronizarEventos extends EventoReproductivoEvent {}
