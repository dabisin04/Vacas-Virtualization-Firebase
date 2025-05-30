import 'package:vacas/domain/entities/animal.dart';
import 'package:vacas/domain/repositories/animal_repository.dart';
import 'dart:io';

class AnimalRepositoryHybrid implements AnimalRepository {
  final AnimalRepository localRepository;
  final AnimalRepository firebaseRepository;

  AnimalRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> addAnimal(Animal animal) async {
    await Future.wait([
      localRepository.addAnimal(animal),
      firebaseRepository.addAnimal(animal),
    ]);
  }

  @override
  Future<void> updateAnimal(Animal animal) async {
    await Future.wait([
      localRepository.updateAnimal(animal),
      firebaseRepository.updateAnimal(animal),
    ]);
  }

  @override
  Future<void> deleteAnimal(String id) async {
    await Future.wait([
      localRepository.deleteAnimal(id),
      firebaseRepository.deleteAnimal(id),
    ]);
  }

  @override
  Future<Animal?> getAnimalById(String id) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getAnimalById(id);
  }

  @override
  Future<List<Animal>> getAllAnimals({required String farmId}) async {
    return await localRepository.getAllAnimals(farmId: farmId);
  }

  @override
  Future<String> uploadAnimalImage({
    required String animalId,
    required File imageFile,
  }) async {
    // Subir imagen únicamente a la API
    final url = await localRepository.uploadAnimalImage(
      animalId: animalId,
      imageFile: imageFile,
    );

    // Guardar solo la URL resultante en Firestore (si fue exitosa)
    if (url.isNotEmpty) {
      final animal = await localRepository.getAnimalById(animalId);
      if (animal != null) {
        final actualizado = animal.copyWith(fotoUrl: url);
        await firebaseRepository
            .updateAnimal(actualizado); // Solo guarda la URL
      }
    }

    return url;
  }

  @override
  Future<String> saveImageLocally(File imageFile, String animalId) async {
    return await localRepository.saveImageLocally(imageFile, animalId);
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
