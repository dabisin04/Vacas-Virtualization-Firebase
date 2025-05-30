import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vacas/core/constants/api_constants.dart';
import 'package:vacas/domain/entities/animal.dart';
import 'package:vacas/application/bloc/animal/animal_bloc.dart';
import 'package:vacas/application/bloc/animal/animal_event.dart';
import 'package:vacas/presentation/screens/screensnavigators/produccion_page.dart';
import 'package:vacas/presentation/screens/screensnavigators/peso_page.dart';
import 'package:vacas/presentation/screens/screensnavigators/salud_page.dart';

class DetalleAnimalPage extends StatelessWidget {
  final Animal animal;

  const DetalleAnimalPage({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final AnimalBloc bloc = context.read<AnimalBloc>();

    // Verifica si la imagen ya fue sincronizada
    if ((animal.fotoUrl == null || animal.fotoUrl!.isEmpty) &&
        animal.localFotoUrl != null &&
        File(animal.localFotoUrl!).existsSync()) {
      Future.microtask(() async {
        bloc.add(ActualizarFotoAnimal(animal.id, File(animal.localFotoUrl!)));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.nombre),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimalImage(animal),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nombre: ${animal.nombre}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Propósito: ${animal.proposito}'),
                      Text('Sexo: ${animal.tipo}'),
                      Text('Etapa desarrollo: ${obtenerEtapa(animal)}'),
                      Text('Código: ${animal.codigoReferencia}'),
                      Text(
                          'Nacimiento: ${DateFormat('dd/MM/yyyy').format(animal.fechaNacimiento)}'),
                      Text(
                          'Edad: ${calculateAge(animal.fechaNacimiento)} años'),
                      Text('Raza: ${animal.raza}'),
                      Text('Ganadería: ${animal.ganaderia}'),
                      Text('Corral: ${animal.corral}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProduccionPage(animal: animal),
                        ),
                      );
                    },
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child:
                            Text('Producción', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthPage(animal: animal),
                        ),
                      );
                    },
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Salud', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PesoPage(animal: animal),
                        ),
                      );
                    },
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Peso', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalImage(Animal animal) {
    ImageProvider? imageProvider;

    // Prioridad 1: Imagen remota si está definida
    if (animal.fotoUrl != null && animal.fotoUrl!.isNotEmpty) {
      final url =
          Uri.parse(ApiConstants.baseUrl).resolve(animal.fotoUrl!).toString();
      imageProvider = NetworkImage(url);
    }
    // Prioridad 2: Imagen local si existe
    else if (animal.localFotoUrl != null &&
        File(animal.localFotoUrl!).existsSync()) {
      imageProvider = FileImage(File(animal.localFotoUrl!));
    }

    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 3),
        borderRadius: BorderRadius.circular(8),
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: imageProvider == null
          ? Center(child: Icon(Icons.pets, size: 80, color: Colors.grey[600]))
          : null,
    );
  }

  String calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age.toString();
  }

  String obtenerEtapa(Animal animal) {
    final hoy = DateTime.now();
    final edadMeses = (hoy.year - animal.fechaNacimiento.year) * 12 +
        (hoy.month - animal.fechaNacimiento.month);

    if (edadMeses < 6) {
      return 'Ternero';
    } else if (edadMeses < 18) {
      return animal.tipo == 'Hembra' ? 'Novilla' : 'Torete';
    } else {
      return animal.tipo == 'Hembra' ? 'Vaca' : 'Toro';
    }
  }
}
