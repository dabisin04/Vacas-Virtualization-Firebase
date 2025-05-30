import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/domain/entities/farm.dart';
import 'package:vacas/domain/repositories/farm_repository.dart';
import 'dart:io';

class FarmRepositoryFirestore implements FarmRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> createFarm(Farm farm) async {
    try {
      await firestore.collection('farms').doc(farm.id).set(farm.toJson());
      print('✅ Finca guardada en Firestore');
    } catch (e) {
      print('❌ Error al guardar finca en Firestore: $e');
    }
  }

  @override
  Future<void> updateFarm(Farm farm) async {
    try {
      await firestore.collection('farms').doc(farm.id).update(farm.toJson());
      print('✅ Finca actualizada en Firestore');
    } catch (e) {
      print('❌ Error al actualizar finca en Firestore: $e');
    }
  }

  @override
  Future<void> deleteFarm(String id) async {
    try {
      await firestore.collection('farms').doc(id).delete();
      // Si también gestionas usuario_finca en Firestore, elimínalos aquí.
      print('✅ Finca eliminada de Firestore');
    } catch (e) {
      print('❌ Error al eliminar finca en Firestore: $e');
    }
  }

  @override
  Future<Farm?> getFarmById(String id) async {
    try {
      final doc = await firestore.collection('farms').doc(id).get();
      if (doc.exists) {
        return Farm.fromJson(doc.data()!);
      }
    } catch (e) {
      print('❌ Error al obtener finca por ID en Firestore: $e');
    }
    return null;
  }

  @override
  Future<List<Farm>> getFarmsByUser(String userId) async {
    try {
      // Si tienes la relación usuario_finca en otra colección, podrías consultarla primero
      final snapshot = await firestore
          .collection('farms')
          .where('usuarios',
              arrayContains:
                  userId) // debes guardar `usuarios` como array de IDs
          .get();

      return snapshot.docs.map((doc) => Farm.fromJson(doc.data())).toList();
    } catch (e) {
      print('❌ Error al obtener fincas por usuario en Firestore: $e');
      return [];
    }
  }

  @override
  Future<String> uploadFarmImage({
    required String farmId,
    required File imageFile,
  }) async {
    print(
        '📌 FirebaseStorage desactivado: solo guardaremos la URL en Firestore');
    return ''; // Evita subir a Firebase
  }

  @override
  Future<void> syncWithServer() async {
    // Implementar sincronización con Firestore
  }
}
