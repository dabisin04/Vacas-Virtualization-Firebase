import 'package:equatable/equatable.dart';
import '../../../domain/entities/chequeo_salud.dart';

abstract class ChequeoSaludState extends Equatable {
  const ChequeoSaludState();
  @override
  List<Object?> get props => [];
}

class ChequeoInicial extends ChequeoSaludState {}

class ChequeoCargando extends ChequeoSaludState {}

class ChequeosCargados extends ChequeoSaludState {
  final List<ChequeoSalud> chequeos;
  const ChequeosCargados(this.chequeos);

  @override
  List<Object?> get props => [chequeos];
}

class ChequeoError extends ChequeoSaludState {
  final String mensaje;
  const ChequeoError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
