// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:vacas/application/bloc/farm/farm_bloc.dart';
import 'package:vacas/application/bloc/farm/farm_event.dart';
import 'package:vacas/application/bloc/farm/farm_state.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_bloc.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_event.dart';
import 'package:vacas/core/services/session_service.dart';
import '../../../domain/entities/farm.dart';
import '../../../domain/entities/usuario_finca.dart';

class CrearFincaPage extends StatefulWidget {
  const CrearFincaPage({super.key});

  @override
  State<CrearFincaPage> createState() => _CrearFincaPageState();
}

class _CrearFincaPageState extends State<CrearFincaPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  File? imagenSeleccionada;
  List<Farm> fincas = [];

  @override
  void initState() {
    super.initState();
    _cargarFincasDelUsuarioSiExisten();
  }

  void _cargarFincasDelUsuarioSiExisten() async {
    final usuario = await SessionService.getUsuario();
    if (usuario == null) return;

    final fincaIds = await SessionService.getFincasDelUsuario();

    if (fincaIds.isNotEmpty) {
      final farmBloc = context.read<FarmBloc>();
      for (var id in fincaIds) {
        farmBloc.add(CargarFincaPorId(id));
      }
    }
  }

  void _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imagenSeleccionada = File(picked.path);
      });
    }
  }

  void _quitarImagen() {
    setState(() => imagenSeleccionada = null);
  }

  void _crearFinca() async {
    final nombre = nombreController.text.trim();
    final ubicacion = ubicacionController.text.trim();
    final descripcion = descripcionController.text.trim();

    if (nombre.isEmpty || ubicacion.isEmpty) {
      _mostrarError("Nombre y ubicación son obligatorios.");
      return;
    }

    final usuario = await SessionService.getUsuario();
    if (usuario == null) {
      _mostrarError("Sesión inválida. Inicia sesión de nuevo.");
      return;
    }

    final now = DateTime.now();
    final idFinca = const Uuid().v4();

    final finca = Farm(
      id: idFinca,
      nombre: nombre,
      ubicacion: ubicacion,
      descripcion: descripcion,
      propietarioId: usuario.id,
      createdAt: now,
      updatedAt: now,
      fotoUrl: null,
    );

    final relacion = UsuarioFinca(
      id: const Uuid().v4(),
      userId: usuario.id,
      farmId: idFinca,
    );

    context.read<FarmBloc>().add(CrearFinca(finca));
    context.read<UsuarioFincaBloc>().add(AsignarUsuarioAFinca(relacion));
    await SessionService.setFincaSeleccionada(idFinca);

    // Delegar la subida de la imagen al Bloc
    if (imagenSeleccionada != null) {
      context.read<FarmBloc>().add(
            ActualizarFotoFinca(finca, imagenSeleccionada!),
          );
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<FarmBloc, FarmState>(
        listener: (context, state) async {
          if (state is FincasCargadas) {
            setState(() => fincas = state.fincas);
          } else if (state is FincaCargada) {
            if (!fincas.any((f) => f.id == state.finca.id)) {
              setState(() => fincas.add(state.finca));
            }
          } else if (state is FarmError) {
            _mostrarError(state.mensaje);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'CREAR FINCA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (imagenSeleccionada != null)
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(imagenSeleccionada!),
                      ),
                      TextButton.icon(
                        onPressed: _quitarImagen,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Quitar imagen'),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _seleccionarImagen,
                    icon: const Icon(Icons.photo),
                    label: const Text('Seleccionar Foto (opcional)'),
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.business, color: Colors.blueAccent),
                    labelText: 'Nombre de la finca',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: ubicacionController,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.location_on, color: Colors.blueAccent),
                    labelText: 'Ubicación',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.info_outline, color: Colors.blueAccent),
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state is FarmCargando ? null : _crearFinca,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: state is FarmCargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear finca'),
                ),
                const SizedBox(height: 30),
                if (fincas.isNotEmpty) ...[
                  const Text(
                    'Tus fincas registradas:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  ...fincas.map(
                    (finca) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading:
                            const Icon(Icons.agriculture, color: Colors.green),
                        title: Text(finca.nombre),
                        subtitle: Text(finca.ubicacion),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
