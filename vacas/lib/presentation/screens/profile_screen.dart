// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/domain/entities/farm.dart';
import 'package:vacas/domain/enums/rol_usuario.dart';
import 'package:vacas/presentation/screens/crear_finca_page.dart';
import 'package:vacas/application/bloc/farm/farm_bloc.dart';
import 'package:vacas/application/bloc/farm/farm_event.dart';
import 'package:vacas/application/bloc/farm/farm_state.dart';
import 'package:vacas/core/constants/api_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? fincaId;
  bool _eventoEnviado = false;
  RolUsuario? userRole;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_eventoEnviado) {
      _loadUserAndFincaData();
    }
  }

  Future<void> _loadUserAndFincaData() async {
    final usuario = await SessionService.getUsuario();
    final id = await SessionService.getFincaSeleccionada();

    if (usuario != null) {
      setState(() {
        userRole = usuario.rol;
        fincaId = id;
        _eventoEnviado = true;
      });

      final farmBloc = context.read<FarmBloc>();

      if (usuario.rol == RolUsuario.administrador) {
        farmBloc.add(CargarFincasDelUsuario(usuario.id));
      } else {
        final fincaIds = await SessionService.getFincasDelUsuario();
        for (final fId in fincaIds) {
          farmBloc.add(CargarFincaPorId(fId));
        }
      }

      if (id != null && id.isNotEmpty) {
        farmBloc.add(CargarFincaPorId(id));
      }
    }
  }

  Widget _buildUserProfile() {
    return FutureBuilder(
      future: SessionService.getUsuario(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final usuario = snapshot.data!;
        return Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              usuario.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              usuario.email,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            Text(
              'Rol: ${usuario.rol.toString().split('.').last}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildFincasList(List<Farm> fincas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fincas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...fincas.map((finca) {
          ImageProvider? imageProvider;
          if (finca.fotoUrl != null && finca.fotoUrl!.isNotEmpty) {
            final url = Uri.parse(ApiConstants.baseUrl)
                .resolve(finca.fotoUrl!)
                .toString();
            imageProvider = NetworkImage(url);
          } else if (finca.localFotoUrl != null &&
              File(finca.localFotoUrl!).existsSync()) {
            imageProvider = FileImage(File(finca.localFotoUrl!));
          }

          if (finca.fotoUrl == null &&
              finca.localFotoUrl != null &&
              File(finca.localFotoUrl!).existsSync()) {
            Future.microtask(() {
              context
                  .read<FarmBloc>()
                  .add(ActualizarFotoFinca(finca, File(finca.localFotoUrl!)));
            });
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: imageProvider != null
                  ? CircleAvatar(backgroundImage: imageProvider)
                  : const CircleAvatar(child: Icon(Icons.business)),
              title: Text(finca.nombre),
              subtitle: Text(finca.ubicacion),
              trailing: finca.id == fincaId
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () async {
                await SessionService.setFincaSeleccionada(finca.id);
                setState(() => fincaId = finca.id);
                context.read<FarmBloc>().add(CargarFincaPorId(finca.id));
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFincaSeleccionadaCard(Farm finca) {
    ImageProvider? imageProvider;
    if (finca.fotoUrl != null && finca.fotoUrl!.isNotEmpty) {
      final url =
          Uri.parse(ApiConstants.baseUrl).resolve(finca.fotoUrl!).toString();
      imageProvider = NetworkImage(url);
    } else if (finca.localFotoUrl != null &&
        File(finca.localFotoUrl!).existsSync()) {
      imageProvider = FileImage(File(finca.localFotoUrl!));
    }

    if (finca.fotoUrl == null &&
        finca.localFotoUrl != null &&
        File(finca.localFotoUrl!).existsSync()) {
      Future.microtask(() {
        context
            .read<FarmBloc>()
            .add(ActualizarFotoFinca(finca, File(finca.localFotoUrl!)));
      });
    }

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileRowScrollable(label: 'Nombre', value: finca.nombre),
                  ProfileRowScrollable(
                      label: 'Ubicación', value: finca.ubicacion),
                  ProfileRowScrollable(
                      label: 'Descripción', value: finca.descripcion),
                ],
              ),
            ),
            const SizedBox(width: 12),
            imageProvider != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image(
                      image: imageProvider,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.photo, size: 100, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: BlocBuilder<FarmBloc, FarmState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildUserProfile(),
                const Divider(),
                if (state is FincasCargadas && state.fincas.isNotEmpty)
                  _buildFincasList(state.fincas),
                if (fincaId != null &&
                    ((state is FincaCargada && state.finca.id == fincaId) ||
                        (state is FincasCargadas &&
                            state.fincas.any((f) => f.id == fincaId)))) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Finca Seleccionada',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (state is FincaCargada && state.finca.id == fincaId)
                    _buildFincaSeleccionadaCard(state.finca),
                  if (state is FincasCargadas)
                    _buildFincaSeleccionadaCard(
                        state.fincas.firstWhere((f) => f.id == fincaId)),
                ],
                if (state is FarmError)
                  Center(child: Text('Error: ${state.mensaje}')),
              ],
            ),
          );
        },
      ),
      floatingActionButton: userRole == RolUsuario.administrador
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrearFincaPage()),
                );
              },
              backgroundColor: Colors.blue,
              tooltip: 'Editar o crear finca',
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }
}

class ProfileRowScrollable extends StatelessWidget {
  final String label;
  final String value;

  const ProfileRowScrollable({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }
}
