import '../../domain/entities/animal.dart';
import '../../domain/entities/farm.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/repositories/farm_repository.dart';

class CreateFarm {
  final FarmRepository farmRepository;
  final AnimalRepository animalRepository;

  CreateFarm(this.farmRepository, this.animalRepository);

  Future<void> execute(Farm farm, List<Animal> animals) async {
    await farmRepository.createFarm(farm);

    for (var animal in animals) {
      await animalRepository.addAnimal(animal);
    }
  }
}
