// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../application/bloc/produccion_leche/produccion_leche_bloc.dart';
import '../../../application/bloc/produccion_leche/produccion_leche_event.dart';
import '../../../application/bloc/produccion_leche/produccion_leche_state.dart';
import '../../../core/services/session_service.dart';
import '../../../domain/entities/animal.dart';
import '../../../domain/entities/produccion_leche.dart';

class ProduccionPage extends StatefulWidget {
  final Animal animal;

  const ProduccionPage({super.key, required this.animal});

  @override
  State<ProduccionPage> createState() => _ProduccionPageState();
}

class _ProduccionPageState extends State<ProduccionPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProduccionLecheBloc>().add(CargarProduccion(widget.animal.id));
  }

  void _registrarProduccion() {
    final lecheController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registrar Producción de Leche"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Text(
                "Fecha: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
              ),
            ),
            TextField(
              controller: lecheController,
              decoration:
                  const InputDecoration(labelText: "Cantidad Leche (L)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              if (lecheController.text.isNotEmpty) {
                final usuario = await SessionService.getUsuario();
                final nueva = ProduccionLeche(
                  id: const Uuid().v4(),
                  farmId: widget.animal.farmId,
                  animalId: widget.animal.id,
                  fecha: selectedDate,
                  cantidadLitros: double.tryParse(lecheController.text) ?? 0,
                  registradoPor: usuario?.id ?? 'desconocido',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                context
                    .read<ProduccionLecheBloc>()
                    .add(AgregarProduccion(nueva));
                Navigator.of(context).pop();
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget _buildTablaProduccion(List<ProduccionLeche> producciones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Historial de Producción",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.blueAccent),
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Fecha",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Leche (L)",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            ...producciones.map(
              (p) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(DateFormat('yyyy-MM-dd').format(p.fecha)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(p.cantidadLitros.toStringAsFixed(2)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _registrarProduccion,
            icon: const Icon(Icons.add),
            label: const Text("Registrar Nueva"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Producción de Leche"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ProduccionLecheBloc, ProduccionLecheState>(
          builder: (context, state) {
            if (state is ProduccionCargando) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProduccionCargada) {
              return SingleChildScrollView(
                  child: _buildTablaProduccion(state.lista));
            } else if (state is ProduccionError) {
              return Center(child: Text(state.mensaje));
            }
            return const Center(child: Text("No hay datos disponibles"));
          },
        ),
      ),
    );
  }
}
