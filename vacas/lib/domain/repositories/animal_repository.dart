import '../entities/animal.dart';
import 'dart:io';

abstract class AnimalRepository {
  Future<void> addAnimal(Animal animal);
  Future<void> updateAnimal(Animal animal);
  Future<void> deleteAnimal(String id);
  Future<Animal?> getAnimalById(String id);
  Future<List<Animal>> getAllAnimals({required String farmId});
  Future<void> syncWithServer();
  Future<String> uploadAnimalImage({
    required String animalId,
    required File imageFile,
  });
  Future<String> saveImageLocally(File imageFile, String animalId);
}
