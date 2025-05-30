import 'package:vacas/domain/entities/farm.dart';
import 'package:vacas/domain/repositories/farm_repository.dart';
import 'dart:io';

class FarmRepositoryHybrid implements FarmRepository {
  final FarmRepository localRepository;
  final FarmRepository firebaseRepository;

  FarmRepositoryHybrid({
    required this.localRepository,
    required this.firebaseRepository,
  });

  @override
  Future<void> createFarm(Farm farm) async {
    await Future.wait([
      localRepository.createFarm(farm),
      firebaseRepository.createFarm(farm),
    ]);
  }

  @override
  Future<void> updateFarm(Farm farm) async {
    await Future.wait([
      localRepository.updateFarm(farm),
      firebaseRepository.updateFarm(farm),
    ]);
  }

  @override
  Future<void> deleteFarm(String id) async {
    await Future.wait([
      localRepository.deleteFarm(id),
      firebaseRepository.deleteFarm(id),
    ]);
  }

  @override
  Future<Farm?> getFarmById(String id) async {
    // Prioriza lectura local por eficiencia
    return await localRepository.getFarmById(id);
  }

  @override
  Future<List<Farm>> getFarmsByUser(String userId) async {
    return await localRepository.getFarmsByUser(userId);
  }

  @override
  Future<String> uploadFarmImage({
    required String farmId,
    required File imageFile,
  }) async {
    // Subir imagen únicamente a la API
    final url = await localRepository.uploadFarmImage(
      farmId: farmId,
      imageFile: imageFile,
    );

    // Guardar solo la URL resultante en Firestore (si fue exitosa)
    if (url.isNotEmpty) {
      final finca = await localRepository.getFarmById(farmId);
      if (finca != null) {
        final actualizada = finca.copyWith(fotoUrl: url);
        await firebaseRepository.updateFarm(actualizada); // Solo guarda la URL
      }
    }

    return url;
  }

  @override
  Future<void> syncWithServer() async {
    await Future.wait([
      localRepository.syncWithServer(),
      firebaseRepository.syncWithServer(),
    ]);
  }
}
