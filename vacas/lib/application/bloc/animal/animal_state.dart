import 'package:equatable/equatable.dart';
import '../../../domain/entities/animal.dart';

abstract class AnimalState extends Equatable {
  const AnimalState();
  @override
  List<Object?> get props => [];
}

class AnimalInicial extends AnimalState {}

class AnimalCargando extends AnimalState {}

class AnimalesCargados extends AnimalState {
  final List<Animal> animales;
  const AnimalesCargados(this.animales);

  @override
  List<Object?> get props => [animales];
}

class AnimalError extends AnimalState {
  final String mensaje;
  const AnimalError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

class AnimalAgregadoConExito extends AnimalState {
  final Animal animal;
  const AnimalAgregadoConExito(this.animal);

  @override
  List<Object?> get props => [animal];
}
