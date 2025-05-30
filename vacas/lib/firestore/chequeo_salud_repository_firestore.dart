import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/domain/entities/chequeo_salud.dart';
import 'package:vacas/domain/repositories/chequeo_salud_repository.dart';

class ChequeoSaludRepositoryFirestore implements ChequeoSaludRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addChequeo(ChequeoSalud chequeo) async {
    try {
      await firestore
          .collection('chequeos_salud')
          .doc(chequeo.id)
          .set(chequeo.toJson());
      print('✅ Chequeo guardado en Firestore');
    } catch (e) {
      print('❌ Error al guardar chequeo en Firestore: $e');
    }
  }

  @override
  Future<void> updateChequeo(ChequeoSalud chequeo) async {
    try {
      await firestore
          .collection('chequeos_salud')
          .doc(chequeo.id)
          .update(chequeo.toJson());
      print('✅ Chequeo actualizado en Firestore');
    } catch (e) {
      print('❌ Error al actualizar chequeo en Firestore: $e');
    }
  }

  @override
  Future<void> deleteChequeo(String id) async {
    try {
      await firestore.collection('chequeos_salud').doc(id).delete();
      print('✅ Chequeo eliminado de Firestore');
    } catch (e) {
      print('❌ Error al eliminar chequeo en Firestore: $e');
    }
  }

  @override
  Future<List<ChequeoSalud>> getChequeosByAnimal(String animalId) async {
    try {
      final snapshot = await firestore
          .collection('chequeos_salud')
          .where('animal_id', isEqualTo: animalId)
          .get();

      return snapshot.docs
          .map((doc) => ChequeoSalud.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener chequeos en Firestore: $e');
      return [];
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Este repositorio ya trabaja directo en Firestore (es la fuente remota),
    // así que no necesita sincronización adicional desde local.
    print(
        '🔄 Firestore ya está sincronizado, no se requiere syncWithServer().');
  }
}
