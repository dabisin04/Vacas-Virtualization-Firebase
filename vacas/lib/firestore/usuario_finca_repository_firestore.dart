import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vacas/domain/entities/usuario_finca.dart';
import 'package:vacas/domain/repositories/usuario_finca_repository.dart';

class UsuarioFincaRepositoryFirestore implements UsuarioFincaRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> asignarUsuarioAFinca(UsuarioFinca relacion) async {
    try {
      await firestore
          .collection('usuario_finca')
          .doc(relacion.id)
          .set(relacion.toJson());
      print('✅ Relación usuario-finca guardada en Firestore');
    } catch (e) {
      print('❌ Error al guardar relación en Firestore: $e');
    }
  }

  @override
  Future<List<String>> getFincaIdsByUsuario(String userId) async {
    try {
      final snapshot = await firestore
          .collection('usuario_finca')
          .where('user_id', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['farm_id'] as String)
          .toList();
    } catch (e) {
      print('❌ Error al obtener fincas por usuario: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getUsuarioIdsByFinca(String farmId) async {
    try {
      final snapshot = await firestore
          .collection('usuario_finca')
          .where('farm_id', isEqualTo: farmId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['user_id'] as String)
          .toList();
    } catch (e) {
      print('❌ Error al obtener usuarios por finca: $e');
      return [];
    }
  }

  @override
  Future<void> eliminarRelacion(String id) async {
    try {
      await firestore.collection('usuario_finca').doc(id).delete();
      print('✅ Relación usuario-finca eliminada de Firestore');
    } catch (e) {
      print('❌ Error al eliminar relación en Firestore: $e');
    }
  }

  @override
  Future<void> syncWithServer() async {
    // Implementar sincronización con Firestore
  }
}
