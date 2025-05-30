import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/domain/entities/vacuna.dart';
import 'package:vacas/domain/repositories/vacuna_repository.dart';

class VacunaRepositoryFirestore implements VacunaRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addVacuna(Vacuna vacuna) async {
    try {
      await firestore.collection('vacunas').doc(vacuna.id).set(vacuna.toJson());
      print('✅ Vacuna guardada en Firestore');
    } catch (e) {
      print('❌ Error al guardar vacuna en Firestore: $e');
    }
  }

  @override
  Future<void> updateVacuna(Vacuna vacuna) async {
    try {
      await firestore
          .collection('vacunas')
          .doc(vacuna.id)
          .update(vacuna.toJson());
      print('✅ Vacuna actualizada en Firestore');
    } catch (e) {
      print('❌ Error al actualizar vacuna en Firestore: $e');
    }
  }

  @override
  Future<void> deleteVacuna(String id) async {
    try {
      await firestore.collection('vacunas').doc(id).delete();
      print('✅ Vacuna eliminada de Firestore');
    } catch (e) {
      print('❌ Error al eliminar vacuna de Firestore: $e');
    }
  }

  @override
  Future<List<Vacuna>> getVacunasByAnimal(String animalId) async {
    try {
      final snapshot = await firestore
          .collection('vacunas')
          .where('animal_id', isEqualTo: animalId)
          .orderBy('fecha') // opcional: si deseas mostrar orden cronológico
          .get();

      return snapshot.docs.map((doc) => Vacuna.fromJson(doc.data())).toList();
    } catch (e) {
      print('❌ Error al obtener vacunas de Firestore: $e');
      return [];
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Firestore ya es la fuente remota, no requiere sincronización.
    print('🔄 Firestore es el origen principal. No requiere syncWithServer().');
  }
}
