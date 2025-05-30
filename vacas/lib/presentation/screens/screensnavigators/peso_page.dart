import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../application/bloc/peso/peso_bloc.dart';
import '../../../application/bloc/peso/peso_event.dart';
import '../../../application/bloc/peso/peso_state.dart';
import '../../../core/services/session_service.dart';
import '../../../domain/entities/animal.dart';
import '../../../domain/entities/peso.dart';

class PesoPage extends StatefulWidget {
  final Animal animal;
  const PesoPage({super.key, required this.animal});

  @override
  State<PesoPage> createState() => _PesoPageState();
}

class _PesoPageState extends State<PesoPage> {
  @override
  void initState() {
    super.initState();
    context.read<PesoBloc>().add(CargarPesos(widget.animal.id));
  }

  void _registrarPeso() {
    final pesoController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registrar Peso"),
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
              controller: pesoController,
              decoration: const InputDecoration(labelText: "Peso (kg)"),
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
              if (pesoController.text.isNotEmpty) {
                final usuario = await SessionService.getUsuario();
                final nuevo = Peso(
                  id: const Uuid().v4(),
                  farmId: widget.animal.farmId,
                  animalId: widget.animal.id,
                  pesoKg: double.tryParse(pesoController.text) ?? 0,
                  fecha: selectedDate,
                  registradoPor: usuario?.id ?? 'desconocido',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                context.read<PesoBloc>().add(AgregarPeso(nuevo));
                Navigator.of(context).pop();
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Map<String, List<Peso>> _agruparPesos(List<Peso> pesos) {
    final Map<String, List<Peso>> grupos = {};
    final first = pesos.first.fecha;
    final last = pesos.last.fecha;
    final diferencia = last.difference(first);

    for (final peso in pesos) {
      String clave;
      if (diferencia.inDays <= 14) {
        clave = DateFormat('yyyy-MM-dd').format(peso.fecha);
      } else if (diferencia.inDays <= 30) {
        clave = 'Semana ${weekNumber(peso.fecha)}';
      } else {
        clave = DateFormat('yyyy-MM').format(peso.fecha);
      }
      grupos.putIfAbsent(clave, () => []).add(peso);
    }
    return grupos;
  }

  String weekNumber(DateTime date) {
    final weekOfYear = int.parse(DateFormat('w').format(date));
    return weekOfYear.toString().padLeft(2, '0');
  }

  String _etiquetaClave(String clave) {
    if (clave.contains('-') && clave.length == 10) {
      final date = DateFormat('yyyy-MM-dd').parse(clave);
      return DateFormat('dd/MM').format(date);
    } else if (clave.contains('Semana')) {
      return clave.replaceAll('Semana ', 'Sem ');
    } else if (clave.length == 7) {
      final date = DateFormat('yyyy-MM').parse(clave);
      return DateFormat('MMM', 'es').format(date);
    }
    return clave;
  }

  BarChartData _buildChart(Map<String, List<Peso>> grupos) {
    final keys = grupos.keys.toList();
    final barGroups = <BarChartGroupData>[];
    final etiquetas = <String>[];

    for (int i = 0; i < keys.length; i++) {
      final grupo = grupos[keys[i]]!;
      final promedio =
          grupo.map((e) => e.pesoKg).reduce((a, b) => a + b) / grupo.length;
      final ultimo = grupo.last.pesoKg;

      final label = _etiquetaClave(keys[i]);
      etiquetas.add(label);

      barGroups.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: promedio, color: Colors.blue, width: 12),
          BarChartRodData(toY: ultimo, color: Colors.orange, width: 12),
        ]),
      );
    }

    return BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index >= 0 && index < etiquetas.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(etiquetas[index],
                      style: const TextStyle(fontSize: 10)),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: true),
      barTouchData: BarTouchData(enabled: true),
    );
  }

  Widget _buildTablaPesos(List<Peso> pesos) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Colors.green),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Fecha", style: TextStyle(color: Colors.white)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Peso (kg)", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        ...pesos.map((p) => TableRow(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(DateFormat('yyyy-MM-dd').format(p.fecha)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(p.pesoKg.toStringAsFixed(2)),
              ),
            ])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pesos'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registrarPeso,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PesoBloc, PesoState>(
        builder: (context, state) {
          if (state is PesoCargando) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PesosCargados) {
            final pesos = state.pesos;
            if (pesos.isEmpty) {
              return const Center(
                  child: Text("No hay datos de peso disponibles."));
            }
            final agrupados = _agruparPesos(pesos);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                        height: 300, child: BarChart(_buildChart(agrupados))),
                    const SizedBox(height: 20),
                    _buildTablaPesos(pesos),
                  ],
                ),
              ),
            );
          } else if (state is PesoError) {
            return Center(child: Text(state.mensaje));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
