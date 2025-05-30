// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/domain/entities/user.dart';
import 'package:vacas/domain/enums/rol_usuario.dart';
import 'package:vacas/domain/repositories/usuario_finca_repository.dart';
import 'package:vacas/presentation/screens/login_screen.dart';
import 'package:vacas/presentation/screens/profile_screen.dart';
import 'package:vacas/presentation/screens/crear_finca_page.dart';
import 'package:vacas/presentation/screens/seleccionar_finca_page.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Usuario?>(
        future: SessionService.getUsuario(),
        builder: (context, snapshot) {
          final usuario = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.landscape,
                      color: Colors.blue,
                      size: 80,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Gestión de Finca",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.black),
                title: const Text('Inicio'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.black),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
              ),
              if (usuario?.rol == RolUsuario.administrador) ...[
                ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.black),
                  title: const Text('Agregar Empleado'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/agregar-empleado');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_business, color: Colors.black),
                  title: const Text('Crear Finca'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrearFincaPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.black),
                  title: const Text('Cambiar Finca'),
                  onTap: () async {
                    Navigator.pop(context);
                    final usuario = await SessionService.getUsuario();
                    if (usuario == null) return;

                    final repo = context.read<UsuarioFincaRepository>();
                    final fincaIds =
                        await repo.getFincaIdsByUsuario(usuario.id);

                    if (fincaIds.length > 1) {
                      final fincaActual =
                          await SessionService.getFincaSeleccionada();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeleccionarFincaPage(
                            fincaIds: fincaIds,
                            fincaSeleccionadaId: fincaActual,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('No tienes más de una finca asociada.')),
                      );
                    }
                  },
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  await SessionService.clearSession();
                  await SessionService.setFincasDelUsuario([]);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
