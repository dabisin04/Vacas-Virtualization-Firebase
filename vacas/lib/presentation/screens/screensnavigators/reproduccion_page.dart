import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vacas/application/bloc/evento_reproductivo/evento_reproductivo_bloc.dart';
import 'package:vacas/application/bloc/evento_reproductivo/evento_reproductivo_event.dart';
import 'package:vacas/application/bloc/evento_reproductivo/evento_reproductivo_state.dart';
import '../../../domain/entities/animal.dart';
import '../../../domain/entities/evento_reproductivo.dart';

class ReproduccionPage extends StatefulWidget {
  final Animal animal;

  const ReproduccionPage({super.key, required this.animal});

  @override
  _ReproduccionPageState createState() => _ReproduccionPageState();
}

class _ReproduccionPageState extends State<ReproduccionPage> {
  @override
  void initState() {
    super.initState();
    context.read<EventoReproductivoBloc>().add(CargarEventos(widget.animal.id));
  }

  void _registrarEventoReproductivo() {
    String tipo = 'Inseminación';
    final resultadoController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Registrar Evento Reproductivo"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tipo,
                    decoration:
                        const InputDecoration(labelText: "Tipo de evento"),
                    items: [
                      'Inseminación',
                      'Chequeo',
                      'Parto',
                      'Aborto',
                    ]
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        tipo = value!;
                      });
                    },
                  ),
                  TextField(
                    controller: resultadoController,
                    decoration: const InputDecoration(
                      labelText: "Resultado",
                      hintText: "Ej. Positivo, Nacimiento simple, etc.",
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Text(
                        "Fecha: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (resultadoController.text.trim().isEmpty) return;

                final evento = EventoReproductivo(
                  id: const Uuid().v4(),
                  farmId: widget.animal.farmId,
                  animalId: widget.animal.id,
                  tipo: tipo,
                  fecha: selectedDate,
                  resultado: resultadoController.text.trim(),
                  realizadoPor: widget.animal.createdBy,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                context
                    .read<EventoReproductivoBloc>()
                    .add(AgregarEvento(evento));
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResumenEventos(List<EventoReproductivo> eventos) {
    final resumen = <String, int>{};
    for (var e in eventos) {
      resumen[e.tipo] = (resumen[e.tipo] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Resumen por tipo de evento",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...resumen.entries.map((e) => Text("${e.key}: ${e.value} evento(s)")),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTablaEventos(List<EventoReproductivo> eventos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResumenEventos(eventos),
        const Text(
          "Eventos Reproductivos",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(3),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.blueAccent),
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Fecha", style: TextStyle(color: Colors.white)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Tipo", style: TextStyle(color: Colors.white)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child:
                      Text("Resultado", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            ...eventos.map((evento) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(DateFormat('yyyy-MM-dd').format(evento.fecha)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(evento.tipo),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(evento.resultado),
                  ),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: _registrarEventoReproductivo,
            icon: const Icon(Icons.add),
            label: const Text("Registrar Nuevo Evento"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reproducción"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<EventoReproductivoBloc, EventoReproductivoState>(
          builder: (context, state) {
            if (state is EventoCargando) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EventosCargados) {
              return SingleChildScrollView(
                  child: _buildTablaEventos(state.eventos));
            } else if (state is EventoError) {
              return Center(child: Text(state.mensaje));
            } else {
              return const Center(child: Text("No hay datos disponibles."));
            }
          },
        ),
      ),
    );
  }
}
