// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:vacas/application/bloc/user/user_bloc.dart';
import 'package:vacas/application/bloc/user/user_event.dart';
import 'package:vacas/application/bloc/user/user_state.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_bloc.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_event.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_state.dart';
import 'package:vacas/application/bloc/farm/farm_bloc.dart';
import 'package:vacas/application/bloc/farm/farm_event.dart';
import 'package:vacas/application/bloc/farm/farm_state.dart';
import 'package:vacas/core/services/session_service.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/farm.dart';
import '../../../domain/entities/usuario_finca.dart';
import '../../../domain/enums/rol_usuario.dart';

class AgregarEmpleadoPage extends StatefulWidget {
  const AgregarEmpleadoPage({super.key});

  @override
  State<AgregarEmpleadoPage> createState() => _AgregarEmpleadoPageState();
}

class _AgregarEmpleadoPageState extends State<AgregarEmpleadoPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  RolUsuario? _rolSeleccionado;
  String? _fincaSeleccionadaId;
  List<Farm> fincas = [];

  @override
  void initState() {
    super.initState();
    _cargarFincasDesdeSession();
  }

  void _cargarFincasDesdeSession() async {
    final fincaIds = await SessionService.getFincasDelUsuario();
    final farmBloc = context.read<FarmBloc>();
    for (var id in fincaIds) {
      farmBloc.add(CargarFincaPorId(id));
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _guardarEmpleado() async {
    final nombre = nombreController.text.trim();
    final email = emailController.text.trim();

    if (nombre.isEmpty ||
        email.isEmpty ||
        _rolSeleccionado == null ||
        _fincaSeleccionadaId == null) {
      _mostrarError('Todos los campos son obligatorios.');
      return;
    }

    final usuarioSesion = await SessionService.getUsuario();
    if (usuarioSesion == null) {
      _mostrarError('No se pudo obtener la sesión.');
      return;
    }

    final base = nombre.split(' ').first.toLowerCase();
    final clave =
        '${base.substring(0, base.length.clamp(0, 4))}${_codigoNumerico()}';

    final nuevoUsuario = Usuario(
      id: const Uuid().v4(),
      nombre: nombre,
      email: email,
      rol: _rolSeleccionado!,
      password: clave,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<UsuarioBloc>().add(CrearUsuario(nuevoUsuario));
    context.read<UsuarioFincaBloc>().add(AsignarUsuarioAFinca(
          UsuarioFinca(
              id: const Uuid().v4(),
              userId: nuevoUsuario.id,
              farmId: _fincaSeleccionadaId!),
        ));

    _mostrarDialogoContrasena(clave);
  }

  String _codigoNumerico() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now % 1000).toString().padLeft(3, '0');
  }

  void _mostrarDialogoContrasena(String contrasena) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Empleado creado',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'La contraseña generada para el nuevo empleado es:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: SelectableText(
                contrasena,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: contrasena));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña copiada')),
                );
              },
              icon: const Icon(Icons.copy, color: Colors.blueAccent),
              label: const Text('Copiar contraseña',
                  style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar',
                style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Empleado'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<UsuarioBloc, UsuarioState>(
            listener: (context, state) {
              if (state is UsuarioError) {
                _mostrarError(state.mensaje);
              }
            },
          ),
          BlocListener<UsuarioFincaBloc, UsuarioFincaState>(
            listener: (context, state) {
              if (state is UsuarioFincaError) {
                _mostrarError(state.mensaje);
              }
            },
          ),
        ],
        child: BlocConsumer<FarmBloc, FarmState>(
          listener: (context, state) {
            if (state is FincaCargada &&
                !fincas.any((f) => f.id == state.finca.id)) {
              setState(() {
                fincas.add(state.finca);
              });
              _fincaSeleccionadaId ??= state.finca.id;
            } else if (state is FarmError) {
              _mostrarError(state.mensaje);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text('Nuevo empleado',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<RolUsuario>(
                    value: _rolSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      prefixIcon: Icon(Icons.work, color: Colors.blueAccent),
                      border: OutlineInputBorder(),
                    ),
                    items: RolUsuario.values
                        .where((r) => r != RolUsuario.administrador)
                        .map((rol) => DropdownMenuItem(
                              value: rol,
                              child: Text(rol.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _rolSeleccionado = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (fincas.length > 1)
                    DropdownButtonFormField<String>(
                      value: _fincaSeleccionadaId,
                      decoration: const InputDecoration(
                        labelText: 'Finca destino',
                        prefixIcon:
                            Icon(Icons.agriculture, color: Colors.blueAccent),
                        border: OutlineInputBorder(),
                      ),
                      items: fincas
                          .map((f) => DropdownMenuItem(
                                value: f.id,
                                child: Text(f.nombre),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _fincaSeleccionadaId = value;
                        });
                      },
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _guardarEmpleado,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
