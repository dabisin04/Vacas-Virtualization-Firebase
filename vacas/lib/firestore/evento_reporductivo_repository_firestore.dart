import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/domain/entities/evento_reproductivo.dart';
import 'package:vacas/domain/repositories/evento_reproductivo_repository.dart';

class EventoReproductivoRepositoryFirestore
    implements EventoReproductivoRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addEvento(EventoReproductivo evento) async {
    try {
      await firestore
          .collection('eventos_reproductivos')
          .doc(evento.id)
          .set(evento.toJson());
      print('✅ Evento reproductivo guardado en Firestore');
    } catch (e) {
      print('❌ Error al guardar evento en Firestore: $e');
    }
  }

  @override
  Future<void> updateEvento(EventoReproductivo evento) async {
    try {
      await firestore
          .collection('eventos_reproductivos')
          .doc(evento.id)
          .update(evento.toJson());
      print('✅ Evento actualizado en Firestore');
    } catch (e) {
      print('❌ Error al actualizar evento en Firestore: $e');
    }
  }

  @override
  Future<void> deleteEvento(String id) async {
    try {
      await firestore.collection('eventos_reproductivos').doc(id).delete();
      print('✅ Evento eliminado de Firestore');
    } catch (e) {
      print('❌ Error al eliminar evento en Firestore: $e');
    }
  }

  @override
  Future<List<EventoReproductivo>> getEventosByAnimal(String animalId) async {
    try {
      final snapshot = await firestore
          .collection('eventos_reproductivos')
          .where('animal_id', isEqualTo: animalId)
          .get();
      return snapshot.docs
          .map((doc) => EventoReproductivo.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener eventos por animal: $e');
      return [];
    }
  }

  @override
  Future<List<EventoReproductivo>> getEventosByFarm(String farmId) async {
    try {
      final snapshot = await firestore
          .collection('eventos_reproductivos')
          .where('farm_id', isEqualTo: farmId)
          .get();
      return snapshot.docs
          .map((doc) => EventoReproductivo.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener eventos por finca: $e');
      return [];
    }
  }

  @override
  Future<List<EventoReproductivo>> getAllEventos() async {
    try {
      final snapshot =
          await firestore.collection('eventos_reproductivos').get();
      return snapshot.docs
          .map((doc) => EventoReproductivo.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error al obtener todos los eventos: $e');
      return [];
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Firestore es el servidor, por lo tanto este método puede quedar como no necesario
    print(
        '🔄 Firestore ya es el origen principal. No se requiere sincronización adicional.');
  }
}
