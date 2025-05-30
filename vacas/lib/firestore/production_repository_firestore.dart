import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/domain/entities/produccion_leche.dart';
import 'package:vacas/domain/repositories/produccion_leche_repository.dart';

class ProduccionLecheRepositoryFirestore implements ProduccionLecheRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addProduccion(ProduccionLeche produccion) async {
    try {
      await firestore
          .collection('produccion_leche')
          .doc(produccion.id)
          .set(produccion.toJson());
      print('✅ Producción guardada en Firestore');
    } catch (e) {
      print('❌ Error al guardar producción en Firestore: $e');
    }
  }

  @override
  Future<void> updateProduccion(ProduccionLeche produccion) async {
    try {
      await firestore
          .collection('produccion_leche')
          .doc(produccion.id)
          .update(produccion.toJson());
      print('✅ Producción actualizada en Firestore');
    } catch (e) {
      print('❌ Error al actualizar producción en Firestore: $e');
    }
  }

  @override
  Future<void> deleteProduccion(String id) async {
    try {
      await firestore.collection('produccion_leche').doc(id).delete();
      print('✅ Producción eliminada de Firestore');
    } catch (e) {
      print('❌ Error al eliminar producción en Firestore: $e');
    }
  }

  @override
  Future<List<ProduccionLeche>> getProduccionByAnimal(String animalId) async {
    try {
      final snapshot = await firestore
          .collection('produccion_leche')
          .where('animal_id', isEqualTo: animalId)
          .orderBy('fecha') // opcional si quieres orden cronológico
          .get();

      return snapshot.docs
          .map((doc) => ProduccionLeche.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener producción por animal: $e');
      return [];
    }
  }

  @override
  Future<List<ProduccionLeche>> getAllProduccion() async {
    try {
      final snapshot = await firestore.collection('produccion_leche').get();
      return snapshot.docs
          .map((doc) => ProduccionLeche.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener toda la producción: $e');
      return [];
    }
  }

  @override
  Future<List<ProduccionLeche>> getProduccionByFarm(String farmId) async {
    try {
      final snapshot = await firestore
          .collection('produccion_leche')
          .where('farm_id', isEqualTo: farmId)
          .get();

      return snapshot.docs
          .map((doc) => ProduccionLeche.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener producción por finca: $e');
      return [];
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Este repositorio ya está conectado a Firestore como fuente principal.
    print('🔄 Firestore ya es el origen. Sincronización no requerida.');
  }
}
