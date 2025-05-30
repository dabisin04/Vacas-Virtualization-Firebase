import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static Future<String> subirFotoYObtenerUrl(File imagen,
      {required String carpeta}) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('$carpeta/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imagen);
    return await ref.getDownloadURL();
  }
}
