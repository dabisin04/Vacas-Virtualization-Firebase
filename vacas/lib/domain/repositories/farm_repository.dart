import '../entities/farm.dart';
import 'dart:io';

abstract class FarmRepository {
  Future<void> createFarm(Farm farm);
  Future<void> updateFarm(Farm farm);
  Future<void> deleteFarm(String id);
  Future<Farm?> getFarmById(String id);
  Future<List<Farm>> getFarmsByUser(String userId);
  Future<void> syncWithServer();
  Future<String> uploadFarmImage({
    required String farmId,
    required File imageFile,
  });
}
