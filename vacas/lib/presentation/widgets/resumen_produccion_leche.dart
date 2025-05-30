import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/produccion_leche.dart';

class ResumenProduccionLecheWidget extends StatelessWidget {
  final List<ProduccionLeche> producciones;
  const ResumenProduccionLecheWidget({super.key, required this.producciones});

  @override
  Widget build(BuildContext context) {
    final agrupadoPorMes = <String, List<ProduccionLeche>>{};
    for (final p in producciones) {
      final mes = DateFormat('yyyy-MM').format(p.fecha);
      agrupadoPorMes.putIfAbsent(mes, () => []).add(p);
    }
    final ordenado = agrupadoPorMes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: ordenado.length * 80,
                child: BarChart(_buildBarChartData(ordenado)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: Colors.blue, label: 'Promedio'),
              SizedBox(width: 10),
              _Legend(color: Colors.orange, label: 'Último'),
              SizedBox(width: 10),
              _Legend(color: Colors.green, label: 'Máximo'),
              SizedBox(width: 10),
              _Legend(color: Colors.red, label: 'Mínimo'),
            ],
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData(
      List<MapEntry<String, List<ProduccionLeche>>> ordenado) {
    final groups = <BarChartGroupData>[];

    for (var i = 0; i < ordenado.length; i++) {
      final regs = ordenado[i].value;
      final prom = regs.map((e) => e.cantidadLitros).reduce((a, b) => a + b) /
          regs.length;
      final ultimo = regs.last.cantidadLitros;
      final maximo =
          regs.map((e) => e.cantidadLitros).reduce((a, b) => a > b ? a : b);
      final minimo =
          regs.map((e) => e.cantidadLitros).reduce((a, b) => a < b ? a : b);

      final rods = regs.length == 1
          ? [BarChartRodData(toY: prom, width: 12, color: Colors.blue)]
          : [
              BarChartRodData(toY: prom, width: 10, color: Colors.blue),
              BarChartRodData(toY: ultimo, width: 10, color: Colors.orange),
              BarChartRodData(toY: maximo, width: 10, color: Colors.green),
              BarChartRodData(toY: minimo, width: 10, color: Colors.red),
            ];
      groups.add(BarChartGroupData(x: i, barRods: rods));
    }

    return BarChartData(
      barGroups: groups,
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < ordenado.length) {
                final d = DateFormat('yyyy-MM').parse(ordenado[i].key);
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(DateFormat('MMM', 'es').format(d),
                      style: const TextStyle(fontSize: 10)),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barTouchData: BarTouchData(enabled: true),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      );
}
