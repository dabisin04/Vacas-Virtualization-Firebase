import 'package:equatable/equatable.dart';
import '../../../domain/entities/evento_reproductivo.dart';

abstract class EventoReproductivoState extends Equatable {
  const EventoReproductivoState();
  @override
  List<Object?> get props => [];
}

class EventoInicial extends EventoReproductivoState {}

class EventoCargando extends EventoReproductivoState {}

class EventosCargados extends EventoReproductivoState {
  final List<EventoReproductivo> eventos;
  const EventosCargados(this.eventos);

  @override
  List<Object?> get props => [eventos];
}

class EventoError extends EventoReproductivoState {
  final String mensaje;
  const EventoError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

class EventosGlobalCargados extends EventoReproductivoState {
  final List<EventoReproductivo> eventos;
  const EventosGlobalCargados(this.eventos);
  @override
  List<Object?> get props => [eventos];
}

class EventosPorFincaCargados extends EventoReproductivoState {
  final String farmId;
  final List<EventoReproductivo> eventos;
  const EventosPorFincaCargados(this.farmId, this.eventos);
  @override
  List<Object?> get props => [farmId, eventos];
}
