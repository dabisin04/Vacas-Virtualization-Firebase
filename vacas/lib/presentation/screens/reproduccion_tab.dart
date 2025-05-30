import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/application/bloc/animal/animal_bloc.dart';
import 'package:vacas/application/bloc/animal/animal_event.dart';
import 'package:vacas/application/bloc/animal/animal_state.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/styles/card_animal.dart';

class ReproduccionTab extends StatefulWidget {
  const ReproduccionTab({super.key});

  @override
  State<ReproduccionTab> createState() => _ReproduccionTabState();
}

class _ReproduccionTabState extends State<ReproduccionTab> {
  @override
  void initState() {
    super.initState();
    _cargarAnimales();
  }

  Future<void> _cargarAnimales() async {
    final farmId = await SessionService.getFincaSeleccionada();
    if (farmId != null && mounted) {
      context.read<AnimalBloc>().add(CargarAnimales(farmId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimalBloc, AnimalState>(
      builder: (context, state) {
        if (state is AnimalCargando) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnimalesCargados) {
          final animales = state.animales;
          if (animales.isEmpty) {
            return const Center(child: Text('No hay animales registrados'));
          }
          return ListView.builder(
            itemCount: animales.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/reproduccion',
                  arguments: animales[i],
                );
              },
              child: AnimalCard(animal: animales[i]),
            ),
          );
        } else if (state is AnimalError) {
          return Center(child: Text(state.mensaje));
        }
        return const SizedBox();
      },
    );
  }
}
