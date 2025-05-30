import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/domain/entities/farm.dart';
import 'package:vacas/domain/entities/evento_reproductivo.dart';
import 'package:vacas/domain/entities/produccion_leche.dart';
import 'package:vacas/domain/repositories/farm_repository.dart';
import 'package:vacas/firestore/animal_repository_firestore.dart';
import 'package:vacas/domain/repositories/user_repository.dart';
import 'package:vacas/domain/repositories/usuario_finca_repository.dart';
import 'package:vacas/domain/repositories/vacuna_repository.dart';
import 'package:vacas/domain/repositories/peso_repository.dart';
import 'package:vacas/domain/repositories/tratamiento_repository.dart';
import 'package:vacas/domain/repositories/produccion_leche_repository.dart';
import 'package:vacas/domain/repositories/chequeo_salud_repository.dart';
import 'package:vacas/domain/repositories/evento_reproductivo_repository.dart';
import 'package:vacas/presentation/widgets/resumen_produccion_leche.dart';
import 'package:vacas/presentation/widgets/resumen_reproductivo.dart';
import 'package:vacas/presentation/widgets/custom_drawer.dart';

import '../../../application/bloc/produccion_leche/produccion_leche_bloc.dart';
import '../../../application/bloc/produccion_leche/produccion_leche_event.dart';
import '../../../application/bloc/produccion_leche/produccion_leche_state.dart';

import '../../../application/bloc/evento_reproductivo/evento_reproductivo_bloc.dart';
import '../../../application/bloc/evento_reproductivo/evento_reproductivo_event.dart';
import '../../../application/bloc/evento_reproductivo/evento_reproductivo_state.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  bool mostrarGlobal = false;
  bool mostrarSelector = false;
  bool cargando = true;

  final fincasMap = <String, Farm>{};
  final fincasSeleccionadas = <String, bool>{};

  final datosPorFinca = <String, List<ProduccionLeche>>{};
  List<ProduccionLeche> datosGlobal = [];

  final eventosPorFinca = <String, List<EventoReproductivo>>{};
  List<EventoReproductivo> eventosGlobal = [];

  @override
  void initState() {
    super.initState();
    _cargarFincas();
    _sincronizarTodosLosRepositorios();
  }

  Future<void> _initAsync() async {
    await _sincronizarTodosLosRepositorios();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAsync();
  }

  Future<void> _cargarFincas() async {
    final repo = context.read<FarmRepository>();
    final prodBloc = context.read<ProduccionLecheBloc>();
    final ids = await SessionService.getFincasDelUsuario();

    for (final id in ids) {
      final f = await repo.getFarmById(id);
      if (f != null) {
        fincasMap[id] = f;
        fincasSeleccionadas[id] = false;
      }
    }

    prodBloc.add(CargarProduccionGlobal());
    setState(() => cargando = false);
  }

  void _solicitarDatos() {
    final prodBloc = context.read<ProduccionLecheBloc>();
    final reproBloc = context.read<EventoReproductivoBloc>();

    fincasSeleccionadas.forEach((id, sel) {
      if (sel) {
        prodBloc.add(CargarProduccionPorFinca(id));
        reproBloc.add(CargarEventosPorFinca(id));
      }
    });

    if (mostrarGlobal) {
      prodBloc.add(CargarProduccionGlobal());
      reproBloc.add(CargarEventosGlobal());
    }
  }

  Future<void> _sincronizarTodosLosRepositorios() async {
    final usuarioRepo = context.read<UserRepository>();
    final fincaRepo = context.read<FarmRepository>();
    final animalRepo = AnimalRepositoryFirestore();
    final vacunaRepo = context.read<VacunaRepository>();
    final tratamientoRepo = context.read<TratamientoRepository>();
    final pesoRepo = context.read<PesoRepository>();
    final produccionRepo = context.read<ProduccionLecheRepository>();
    final chequeoRepo = context.read<ChequeoSaludRepository>();
    final eventoRepo = context.read<EventoReproductivoRepository>();
    final relacionRepo = context.read<UsuarioFincaRepository>();

    try {
      await usuarioRepo.syncWithServer();
      await fincaRepo.syncWithServer();
      await animalRepo.syncWithServer();
      await vacunaRepo.syncWithServer();
      await tratamientoRepo.syncWithServer();
      await pesoRepo.syncWithServer();
      await produccionRepo.syncWithServer();
      await chequeoRepo.syncWithServer();
      await eventoRepo.syncWithServer();
      await relacionRepo.syncWithServer();

      print('✅ Todos los datos fueron sincronizados correctamente.');
    } catch (e) {
      print('⚠️ Error al sincronizar algunos datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(
            'Resumen de Producción',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _solicitarDatos,
            ),
          ],
        ),
        drawer: const CustomDrawer(),
        body: SafeArea(
          child: cargando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: Icon(
                          mostrarSelector
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () =>
                            setState(() => mostrarSelector = !mostrarSelector),
                      ),
                    ),
                    if (mostrarSelector) _buildSelector(),
                    const Divider(),
                    Expanded(
                      flex: 2,
                      child: MultiBlocListener(
                        listeners: [
                          BlocListener<ProduccionLecheBloc,
                              ProduccionLecheState>(
                            listener: (context, state) {
                              if (state is ProduccionCargada) {
                                if (mostrarGlobal) {
                                  datosGlobal = state.lista;
                                }
                                final farmIds =
                                    state.lista.map((e) => e.farmId).toSet();
                                for (final id in farmIds) {
                                  if (fincasSeleccionadas[id] == true) {
                                    datosPorFinca[id] = state.lista
                                        .where((e) => e.farmId == id)
                                        .toList();
                                  }
                                }
                                setState(() {});
                              }
                            },
                          ),
                          BlocListener<EventoReproductivoBloc,
                              EventoReproductivoState>(
                            listener: (context, state) {
                              if (state is EventosGlobalCargados &&
                                  mostrarGlobal) {
                                eventosGlobal = state.eventos;
                                setState(() {});
                              } else if (state is EventosPorFincaCargados &&
                                  fincasSeleccionadas[state.farmId] == true) {
                                eventosPorFinca[state.farmId] = state.eventos;
                                setState(() {});
                              }
                            },
                          ),
                        ],
                        child: _graficos(),
                      ),
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sincronizando con Firestore...')),
            );

            try {
              await AnimalRepositoryFirestore().syncWithServer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Sincronización completada!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al sincronizar: $e')),
              );
            }
          },
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Sincronizar Animales'),
        ),
      );

  Widget _buildSelector() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text('Ver Producción Global'),
              value: mostrarGlobal,
              onChanged: (v) {
                setState(() => mostrarGlobal = v ?? false);
                _solicitarDatos();
              },
            ),
            const Divider(),
            ...fincasMap.entries.map((e) => CheckboxListTile(
                  title: Text('${e.value.nombre} (${e.value.ubicacion})'),
                  value: fincasSeleccionadas[e.key],
                  onChanged: (v) {
                    setState(() => fincasSeleccionadas[e.key] = v ?? false);
                    _solicitarDatos();
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _graficos() {
    final widgets = <Widget>[];

    if (mostrarGlobal) {
      if (datosGlobal.isNotEmpty) {
        widgets.addAll([
          const Text('Resumen global - Producción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: ResumenProduccionLecheWidget(producciones: datosGlobal),
          ),
          const SizedBox(height: 16),
        ]);
      }

      if (eventosGlobal.isNotEmpty) {
        widgets.addAll([
          const Text('Resumen global - Reproducción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: ResumenReproduccionWidget(eventos: eventosGlobal),
          ),
          const SizedBox(height: 16),
        ]);
      }
    }

    fincasSeleccionadas.forEach((id, sel) {
      if (sel) {
        if (datosPorFinca[id]?.isNotEmpty == true) {
          widgets.addAll([
            Text('Producción - ${fincasMap[id]?.nombre ?? 'Finca'}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: ResumenProduccionLecheWidget(
                  producciones: datosPorFinca[id]!),
            ),
            const SizedBox(height: 16),
          ]);
        }

        if (eventosPorFinca[id]?.isNotEmpty == true) {
          widgets.addAll([
            Text('Reproducción - ${fincasMap[id]?.nombre ?? 'Finca'}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: ResumenReproduccionWidget(eventos: eventosPorFinca[id]!),
            ),
            const SizedBox(height: 16),
          ]);
        }
      }
    });

    if (widgets.isEmpty) {
      return const Center(
          child: Text('Selecciona al menos una finca o producción global.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(children: widgets),
    );
  }
}
