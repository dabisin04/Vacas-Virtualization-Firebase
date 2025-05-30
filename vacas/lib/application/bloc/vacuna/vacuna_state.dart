import 'package:equatable/equatable.dart';
import '../../../domain/entities/vacuna.dart';

abstract class VacunaState extends Equatable {
  const VacunaState();
  @override
  List<Object?> get props => [];
}

class VacunaInicial extends VacunaState {}

class VacunaCargando extends VacunaState {}

class VacunasCargadas extends VacunaState {
  final List<Vacuna> vacunas;
  const VacunasCargadas(this.vacunas);

  @override
  List<Object?> get props => [vacunas];
}

class VacunaError extends VacunaState {
  final String mensaje;
  const VacunaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
