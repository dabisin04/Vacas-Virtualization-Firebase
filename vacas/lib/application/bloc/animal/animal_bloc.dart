import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/animal_repository.dart';
import 'animal_event.dart';
import 'animal_state.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  final AnimalRepository animalRepository;

  AnimalBloc(this.animalRepository) : super(AnimalInicial()) {
    on<CargarAnimales>(_onCargarAnimales);
    on<AgregarAnimal>(_onAgregarAnimal);
    on<ActualizarAnimal>(_onActualizarAnimal);
    on<EliminarAnimal>(_onEliminarAnimal);
    on<SincronizarAnimales>(_onSincronizarAnimales);
    on<ActualizarFotoAnimal>(_onActualizarFotoAnimal);
  }

  Future<void> _onCargarAnimales(
      CargarAnimales event, Emitter<AnimalState> emit) async {
    emit(AnimalCargando());
    try {
      final animales =
          await animalRepository.getAllAnimals(farmId: event.farmId);
      emit(AnimalesCargados(animales));
    } catch (e) {
      emit(AnimalError("Error al cargar animales: $e"));
    }
  }

  Future<void> _onAgregarAnimal(
      AgregarAnimal event, Emitter<AnimalState> emit) async {
    try {
      await animalRepository.addAnimal(event.animal);
      add(CargarAnimales(event.animal.farmId));
      emit(AnimalAgregadoConExito(event.animal));
    } catch (e) {
      emit(AnimalError("Error al agregar animal: $e"));
    }
  }

  Future<void> _onActualizarAnimal(
      ActualizarAnimal event, Emitter<AnimalState> emit) async {
    try {
      await animalRepository.updateAnimal(event.animal);
      add(CargarAnimales(event.animal.farmId));
    } catch (e) {
      emit(AnimalError("Error al actualizar animal: $e"));
    }
  }

  Future<void> _onEliminarAnimal(
      EliminarAnimal event, Emitter<AnimalState> emit) async {
    try {
      await animalRepository.deleteAnimal(event.animalId);
      // No se sabe el farmId directamente, mejor recargar con un trigger externo
    } catch (e) {
      emit(AnimalError("Error al eliminar animal: $e"));
    }
  }

  Future<void> _onSincronizarAnimales(
      SincronizarAnimales event, Emitter<AnimalState> emit) async {
    try {
      await animalRepository.syncWithServer();
    } catch (e) {
      emit(AnimalError("Error al sincronizar animales: $e"));
    }
  }

  Future<void> _onActualizarFotoAnimal(
      ActualizarFotoAnimal event, Emitter<AnimalState> emit) async {
    emit(AnimalCargando());
    try {
      // 🔼 Subir imagen y obtener URL devuelta por el backend
      final url = await animalRepository.uploadAnimalImage(
        animalId: event.animalId,
        imageFile: event.imagen,
      );

      final localUrl = await animalRepository.saveImageLocally(
        event.imagen,
        event.animalId,
      );

      if (url.isEmpty) {
        emit(const AnimalError(
            "Error al subir la imagen: respuesta vacía del servidor"));
        return;
      }

      // 🧩 Obtener animal actual y crear nueva instancia con URL actualizada
      final animalActual = await animalRepository.getAnimalById(event.animalId);
      if (animalActual == null) {
        emit(const AnimalError("No se encontró el animal"));
        return;
      }

      final animalActualizado = animalActual.copyWith(
        fotoUrl: url,
        localFotoUrl: localUrl,
      );

      // 💾 Actualizar en base de datos local y sincronizar
      await animalRepository.updateAnimal(animalActualizado);

      // 📦 Obtener finca y cargar todos los animales nuevamente
      final animales =
          await animalRepository.getAllAnimals(farmId: animalActual.farmId);

      print('✅ Imagen subida y animal actualizado con nueva URL: $url');
      emit(AnimalesCargados(animales));
    } catch (e) {
      print('❌ Error al subir imagen o actualizar animal: $e');
      emit(AnimalError("Error al actualizar la foto del animal: $e"));
    }
  }
}
