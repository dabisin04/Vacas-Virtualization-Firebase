import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/application/bloc/user/user_bloc.dart';
import 'package:vacas/application/bloc/user/user_event.dart';
import 'package:vacas/application/bloc/user/user_state.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/domain/repositories/usuario_finca_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _iniciarSesion() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (!email.contains('@')) {
      _mostrarError('Ingrese un correo válido.');
      return;
    }
    if (password.isEmpty) {
      _mostrarError('Ingrese una contraseña.');
      return;
    }
    context.read<UsuarioBloc>().add(LoginUsuario(email, password));
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<UsuarioBloc, UsuarioState>(
        listener: (context, state) async {
          if (state is UsuarioAutenticado) {
            final usuario = state.usuario;
            await SessionService.saveUsuario(usuario);

            // Accede al repositorio de relaciones usuario-finca
            final usuarioFincaRepo = context.read<UsuarioFincaRepository>();
            final fincaIds =
                await usuarioFincaRepo.getFincaIdsByUsuario(usuario.id);

            if (fincaIds.isEmpty) {
              _mostrarError(
                  "No tienes fincas asignadas. Contacta al administrador.");
            } else if (fincaIds.length == 1) {
              await SessionService.setFincaSeleccionada(fincaIds.first);
              await SessionService.saveUsuario(usuario);
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else {
              Navigator.pushReplacementNamed(
                context,
                '/seleccionar-finca',
                arguments: fincaIds,
              );
            }
          } else if (state is UsuarioError) {
            _mostrarError(state.mensaje);
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.email_outlined, color: Colors.blueAccent),
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline,
                          color: Colors.blueAccent),
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: state is UsuarioCargando ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: state is UsuarioCargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Ingresar'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
