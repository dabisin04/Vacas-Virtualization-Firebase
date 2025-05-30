import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vacas/application/bloc/chequeo_salud/chequeo_salud_bloc.dart';
import 'package:vacas/application/bloc/chequeo_salud/chequeo_salud_event.dart';
import 'package:vacas/application/bloc/chequeo_salud/chequeo_salud_state.dart';
import 'package:vacas/application/bloc/vacuna/vacuna_bloc.dart';
import 'package:vacas/application/bloc/vacuna/vacuna_event.dart';
import 'package:vacas/application/bloc/vacuna/vacuna_state.dart';
import '../../../domain/entities/animal.dart';
import '../../../domain/entities/chequeo_salud.dart';
import '../../../domain/entities/vacuna.dart';

class HealthPage extends StatefulWidget {
  final Animal animal;

  const HealthPage({super.key, required this.animal});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  bool showChequeos = true;
  bool showVacunas = true;

  @override
  void initState() {
    super.initState();
    context.read<ChequeoSaludBloc>().add(CargarChequeos(widget.animal.id));
    context.read<VacunaBloc>().add(CargarVacunas(widget.animal.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SALUD",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFilterOptions(),
          const SizedBox(height: 16),
          if (showChequeos) _buildChequeosTable(context),
          if (showVacunas) _buildVacunasTable(context),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Filtrar secciones",
            style: TextStyle(fontWeight: FontWeight.bold)),
        CheckboxListTile(
          value: showChequeos,
          onChanged: (value) {
            setState(() => showChequeos = value!);
          },
          title: const Text("Chequeos de Salud"),
        ),
        CheckboxListTile(
          value: showVacunas,
          onChanged: (value) {
            setState(() => showVacunas = value!);
          },
          title: const Text("Vacunas"),
        ),
      ],
    );
  }

  Widget _buildChequeosTable(BuildContext context) {
    return BlocBuilder<ChequeoSaludBloc, ChequeoSaludState>(
      builder: (context, state) {
        if (state is ChequeoCargando) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChequeosCargados) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chequeos de Salud",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Table(
                border: TableBorder.all(color: Colors.black),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.blue),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text("Fecha")),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Diagnóstico")),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Tratamiento")),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Observaciones")),
                    ],
                  ),
                  ...state.chequeos.map((c) => TableRow(children: [
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child:
                                Text(DateFormat('yyyy-MM-dd').format(c.fecha))),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(c.diagnostico)),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(c.tratamiento)),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(c.observaciones)),
                      ])),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () => _showAddChequeoDialog(context),
              )
            ],
          );
        } else {
          return const Text("No se pudieron cargar los chequeos.");
        }
      },
    );
  }

  Widget _buildVacunasTable(BuildContext context) {
    return BlocBuilder<VacunaBloc, VacunaState>(
      builder: (context, state) {
        if (state is VacunaCargando) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VacunasCargadas) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Vacunas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Table(
                border: TableBorder.all(color: Colors.black),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.blue),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text("Fecha")),
                      Padding(
                          padding: EdgeInsets.all(8), child: Text("Vacuna")),
                      Padding(
                          padding: EdgeInsets.all(8), child: Text("Motivo")),
                    ],
                  ),
                  ...state.vacunas.map((v) => TableRow(children: [
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child:
                                Text(DateFormat('yyyy-MM-dd').format(v.fecha))),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(v.nombre)),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(v.motivo)),
                      ])),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () => _showAddVacunaDialog(context),
              )
            ],
          );
        } else {
          return const Text("No se pudieron cargar las vacunas.");
        }
      },
    );
  }

  void _showAddChequeoDialog(BuildContext context) {
    String diagnostico = '';
    String tratamiento = '';
    String observaciones = '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Chequeo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: const InputDecoration(labelText: 'Diagnóstico'),
                onChanged: (v) => diagnostico = v),
            TextField(
                decoration: const InputDecoration(labelText: 'Tratamiento'),
                onChanged: (v) => tratamiento = v),
            TextField(
                decoration: const InputDecoration(labelText: 'Observaciones'),
                onChanged: (v) => observaciones = v),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChequeoSaludBloc>().add(AgregarChequeo(
                    ChequeoSalud(
                      id: UniqueKey().toString(),
                      farmId: widget.animal.farmId,
                      animalId: widget.animal.id,
                      fecha: DateTime.now(),
                      diagnostico: diagnostico,
                      tratamiento: tratamiento,
                      observaciones: observaciones,
                      realizadoPor: widget.animal.createdBy,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  ));
              context
                  .read<ChequeoSaludBloc>()
                  .add(CargarChequeos(widget.animal.id));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Chequeo registrado correctamente")),
              );
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showAddVacunaDialog(BuildContext context) {
    String nombre = '';
    String motivo = '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Vacuna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (v) => nombre = v),
            TextField(
                decoration: const InputDecoration(labelText: 'Motivo'),
                onChanged: (v) => motivo = v),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VacunaBloc>().add(AgregarVacuna(
                    Vacuna(
                      id: UniqueKey().toString(),
                      farmId: widget.animal.farmId,
                      animalId: widget.animal.id,
                      nombre: nombre,
                      motivo: motivo,
                      fecha: DateTime.now(),
                      registradoPor: widget.animal.createdBy,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  ));
              context.read<VacunaBloc>().add(CargarVacunas(widget.animal.id));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Vacuna registrada correctamente")),
              );
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
