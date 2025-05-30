import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/domain/entities/farm.dart';
import 'package:vacas/domain/repositories/farm_repository.dart';

class SeleccionarFincaPage extends StatefulWidget {
  final List<String> fincaIds;
  final String? fincaSeleccionadaId;

  const SeleccionarFincaPage({
    super.key,
    required this.fincaIds,
    this.fincaSeleccionadaId,
  });

  @override
  State<SeleccionarFincaPage> createState() => _SeleccionarFincaPageState();
}

class _SeleccionarFincaPageState extends State<SeleccionarFincaPage> {
  List<Farm> _fincas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFincas();
  }

  Future<void> _cargarFincas() async {
    final farmRepo = context.read<FarmRepository>();
    List<Farm> fincas = [];

    for (final id in widget.fincaIds) {
      final finca = await farmRepo.getFarmById(id);
      if (finca != null) {
        fincas.add(finca);
      }
    }

    if (fincas.isEmpty) {
      // Redirige a la pantalla de creación si no hay fincas válidas
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/crear-finca');
      });
      return;
    }

    setState(() {
      _fincas = fincas;
      _cargando = false;
    });
  }

  void _seleccionarFinca(Farm finca) async {
    await SessionService.setFincaSeleccionada(finca.id);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Finca'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _fincas.isEmpty
              ? const Center(child: Text('No se encontraron fincas.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _fincas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final finca = _fincas[index];
                    final esSeleccionada =
                        finca.id == widget.fincaSeleccionadaId;
                    return Card(
                      elevation: 3,
                      color: esSeleccionada ? Colors.lightBlue[50] : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.agriculture,
                          color: esSeleccionada
                              ? Colors.orange
                              : Colors.blueAccent,
                        ),
                        title: Text(
                          finca.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(finca.ubicacion),
                        trailing: esSeleccionada
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () => _seleccionarFinca(finca),
                      ),
                    );
                  },
                ),
    );
  }
}
