import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/domain/entities/tratamiento.dart';
import 'package:vacas/domain/repositories/tratamiento_repository.dart';

class TratamientoRepositoryFirestore implements TratamientoRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addTratamiento(Tratamiento tratamiento) async {
    try {
      await firestore
          .collection('tratamientos')
          .doc(tratamiento.id)
          .set(tratamiento.toJson());
      print('✅ Tratamiento guardado en Firestore');
    } catch (e) {
      print('❌ Error al guardar tratamiento en Firestore: $e');
    }
  }

  @override
  Future<void> updateTratamiento(Tratamiento tratamiento) async {
    try {
      await firestore
          .collection('tratamientos')
          .doc(tratamiento.id)
          .update(tratamiento.toJson());
      print('✅ Tratamiento actualizado en Firestore');
    } catch (e) {
      print('❌ Error al actualizar tratamiento en Firestore: $e');
    }
  }

  @override
  Future<void> deleteTratamiento(String id) async {
    try {
      await firestore.collection('tratamientos').doc(id).delete();
      print('✅ Tratamiento eliminado de Firestore');
    } catch (e) {
      print('❌ Error al eliminar tratamiento en Firestore: $e');
    }
  }

  @override
  Future<List<Tratamiento>> getTratamientosByAnimal(String animalId) async {
    try {
      final snapshot = await firestore
          .collection('tratamientos')
          .where('animal_id', isEqualTo: animalId)
          .orderBy('fecha') // si tienes campo de fecha y quieres orden
          .get();

      return snapshot.docs
          .map((doc) => Tratamiento.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener tratamientos en Firestore: $e');
      return [];
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Como Firestore es la fuente remota, esta función puede quedar vacía
    print('🔄 Firestore es la fuente principal. Sincronización no requerida.');
  }
}
