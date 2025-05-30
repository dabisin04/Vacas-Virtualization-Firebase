import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/evento_reproductivo.dart';

class ResumenReproduccionWidget extends StatelessWidget {
  final List<EventoReproductivo> eventos;

  const ResumenReproduccionWidget({super.key, required this.eventos});

  @override
  Widget build(BuildContext context) {
    if (eventos.isEmpty) {
      return const Center(child: Text('Sin eventos registrados'));
    }

    final conteo = <String, int>{};
    for (final e in eventos) {
      conteo[e.tipo] = (conteo[e.tipo] ?? 0) + 1;
    }

    final tipos = conteo.keys.toList();
    final palette = List<Color>.generate(tipos.length, (i) {
      final hue = (360 / tipos.length) * i;
      return HSVColor.fromAHSV(1, hue, .6, .9).toColor();
    });

    final total = eventos.length;
    final sections = <PieChartSectionData>[];

    for (var i = 0; i < tipos.length; i++) {
      final tipo = tipos[i];
      final cantidad = conteo[tipo]!;
      final percent = cantidad / total * 100;

      sections.add(
        PieChartSectionData(
          value: cantidad.toDouble(),
          title: '${percent.toStringAsFixed(1)}%',
          radius: 70,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          color: palette[i],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        // 👈 esto soluciona el overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...tipos.mapIndexed((i, tipo) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _Legend(
                  color: palette[i],
                  label: '$tipo (${conteo[tipo]})',
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _MapIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int, E) fn) {
    var index = 0;
    return map((e) => fn(index++, e));
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}
