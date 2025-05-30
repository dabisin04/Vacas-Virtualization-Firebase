import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/animal/animal_bloc.dart';
import '../../../application/bloc/animal/animal_event.dart';
import '../../../application/bloc/animal/animal_state.dart';

class DatosGeneralesPage extends StatelessWidget {
  final String farmId;
  const DatosGeneralesPage({super.key, required this.farmId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Datos Generales"),
      ),
      body: BlocBuilder<AnimalBloc, AnimalState>(
        builder: (context, state) {
          if (state is AnimalInicial) {
            context.read<AnimalBloc>().add(CargarAnimales(farmId));
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnimalCargando) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnimalesCargados) {
            final animales = state.animales;

            int totalAnimales = animales.length;
            int totalHembras = animales.where((a) => a.tipo == 'Hembra').length;
            int totalMachos = animales.where((a) => a.tipo == 'Macho').length;
            int enProduccion = animales
                .where((a) => a.tipo == 'Hembra' && a.proposito == 'Leche')
                .length;
            int novillos = animales
                .where((a) => a.tipo == 'Macho' && a.proposito == 'Carne')
                .length;

            // No hay datos de leche en Animal directamente, así que lo dejamos en 0 por ahora
            double totalLeche = 0;
            double promedioLeche = 0;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCard(Icons.info, "Total Animales",
                    totalAnimales.toString(), Colors.blue),
                _buildCard(Icons.female, "Total Hembras",
                    totalHembras.toString(), Colors.pink),
                _buildCard(Icons.male, "Total Machos", totalMachos.toString(),
                    Colors.blue),
                _buildCard(Icons.production_quantity_limits, "En Producción",
                    enProduccion.toString(), Colors.green),
                _buildCard(Icons.child_care, "Novillos", novillos.toString(),
                    Colors.brown),
                _buildCard(Icons.local_drink, "Total Leche Producción",
                    "${totalLeche.toStringAsFixed(2)} Litros", Colors.orange),
                _buildCard(
                    Icons.analytics,
                    "Promedio Producción Leche",
                    "${promedioLeche.toStringAsFixed(2)} Litros/Día",
                    Colors.teal),
              ],
            );
          } else if (state is AnimalError) {
            return Center(child: Text(state.mensaje));
          } else {
            return const Center(child: Text("Estado desconocido"));
          }
        },
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String subtitle, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
