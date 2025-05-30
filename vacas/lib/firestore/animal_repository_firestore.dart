import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vacas/domain/entities/animal.dart';
import 'package:vacas/domain/repositories/animal_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vacas/core/services/sqlite_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class AnimalRepositoryFirestore implements AnimalRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Database> get _db async => await SQLiteService.instance;

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<String> saveImageLocally(File imageFile, String animalId) async {
    final dir = await getApplicationDocumentsDirectory();
    final localPath = '${dir.path}/$animalId.jpg';
    final savedImage = await imageFile.copy(localPath);
    return savedImage.path;
  }

  @override
  Future<String> uploadAnimalImage({
    required String animalId,
    required File imageFile,
  }) async {
    print(
        '📌 FirebaseStorage desactivado: solo guardaremos la URL en Firestore');
    return ''; // Evita subir a Firebase
  }

  @override
  Future<void> addAnimal(Animal animal) async {
    try {
      await firestore.collection('animals').doc(animal.id).set(animal.toJson());
    } catch (e) {
      print('❌ Error al agregar animal a Firestore: $e');
    }
  }

  @override
  Future<void> updateAnimal(Animal animal) async {
    try {
      await firestore
          .collection('animals')
          .doc(animal.id)
          .update(animal.toJson());
    } catch (e) {
      print('❌ Error al actualizar animal en Firestore: $e');
    }
  }

  @override
  Future<void> deleteAnimal(String id) async {
    try {
      await firestore.collection('animals').doc(id).delete();
    } catch (e) {
      print('❌ Error al eliminar animal de Firestore: $e');
    }
  }

  @override
  Future<Animal?> getAnimalById(String id) async {
    try {
      final doc = await firestore.collection('animals').doc(id).get();
      if (doc.exists) {
        return Animal.fromJson(doc.data()!);
      }
    } catch (e) {
      print('❌ Error al obtener animal de Firestore: $e');
    }
    return null;
  }

  @override
  Future<List<Animal>> getAllAnimals({required String farmId}) async {
    try {
      final querySnapshot = await firestore
          .collection('animals')
          .where('farm_id', isEqualTo: farmId)
          .get();
      return querySnapshot.docs
          .map((doc) => Animal.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener todos los animales: $e');
      return [];
    }
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _isOnline()) return;

    try {
      final db = await _db;
      final localAnimals = await db.query('animals');

      // Agrupamos por farmId para consultas más eficientes
      final Map<String, List<Animal>> animalsByFarm = {};
      for (final a in localAnimals) {
        final animal = Animal.fromJson(a);
        animalsByFarm.putIfAbsent(animal.farmId, () => []).add(animal);
      }

      for (final entry in animalsByFarm.entries) {
        final farmId = entry.key;
        final localList = entry.value;

        final remoteSnapshot = await firestore
            .collection('animals')
            .where('farm_id', isEqualTo: farmId)
            .get();

        final remoteMap = {
          for (final doc in remoteSnapshot.docs)
            doc.id: Animal.fromJson(doc.data())
        };

        final batch = firestore.batch();

        for (final local in localList) {
          final docRef = firestore.collection('animals').doc(local.id);
          final remote = remoteMap[local.id];

          if (remote == null) {
            batch.set(docRef, local.toJson());
          } else if (local.updatedAt.isAfter(remote.updatedAt)) {
            batch.update(docRef, local.toJson());
          }
        }

        await batch.commit();
      }
    } catch (e) {
      print('❌ Error en sincronización con Firestore: $e');
    }
  }
}
