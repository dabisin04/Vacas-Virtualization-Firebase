import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/domain/entities/animal.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;

  const AnimalCard({Key? key, required this.animal}) : super(key: key);

  ImageProvider? _getImageProvider() {
    if (animal.localFotoUrl != null &&
        File(animal.localFotoUrl!).existsSync()) {
      return FileImage(File(animal.localFotoUrl!));
    } else if (animal.fotoUrl != null && animal.fotoUrl!.isNotEmpty) {
      final fullUrl =
          Uri.parse(ApiConstants.baseUrl).resolve(animal.fotoUrl!).toString();
      return NetworkImage(fullUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor:
                  animal.tipo == 'Hembra' ? Colors.pink : Colors.blue,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.pets, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '#${animal.numAnimal}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
