import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/domain/entities/peso.dart';
import 'package:vacas/domain/repositories/peso_repository.dart';

class PesoRepositoryFirestore implements PesoRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addPeso(Peso peso) async {
    try {
      await firestore.collection('pesos').doc(peso.id).set(peso.toJson());
      print('✅ Peso guardado en Firestore');
    } catch (e) {
      print('❌ Error al guardar peso en Firestore: $e');
    }
  }

  @override
  Future<void> updatePeso(Peso peso) async {
    try {
      await firestore.collection('pesos').doc(peso.id).update(peso.toJson());
      print('✅ Peso actualizado en Firestore');
    } catch (e) {
      print('❌ Error al actualizar peso en Firestore: $e');
    }
  }

  @override
  Future<void> deletePeso(String id) async {
    try {
      await firestore.collection('pesos').doc(id).delete();
      print('✅ Peso eliminado de Firestore');
    } catch (e) {
      print('❌ Error al eliminar peso de Firestore: $e');
    }
  }

  @override
  Future<List<Peso>> getPesosByAnimal(String animalId) async {
    try {
      final snapshot = await firestore
          .collection('pesos')
          .where('animal_id', isEqualTo: animalId)
          .orderBy('fecha') // Opcional: si deseas ordenarlos por fecha
          .get();

      return snapshot.docs.map((doc) => Peso.fromJson(doc.data())).toList();
    } catch (e) {
      print('❌ Error al obtener pesos de Firestore: $e');
      return [];
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Firestore ya es el servidor, no se requiere sincronización adicional
    print(
        '🔄 Firestore es la fuente principal. No se requiere syncWithServer().');
  }
}
