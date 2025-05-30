import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:vacas/application/bloc/user/user_bloc.dart';
import 'package:vacas/application/bloc/user/user_event.dart';
import 'package:vacas/application/bloc/user/user_state.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/domain/entities/user.dart';
import 'package:vacas/domain/enums/rol_usuario.dart';
import 'package:vacas/presentation/screens/crear_finca_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _registrarUsuario() {
    final nombre = nombreController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (nombre.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _mostrarError('Todos los campos son obligatorios.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _mostrarError('Ingrese un correo electrónico válido.');
      return;
    }

    if (password.length < 6) {
      _mostrarError('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (password != confirmPassword) {
      _mostrarError('Las contraseñas no coinciden.');
      return;
    }

    final nuevoUsuario = Usuario(
      id: const Uuid().v4(),
      nombre: nombre,
      email: email,
      rol: RolUsuario.administrador,
      password: password,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<UsuarioBloc>().add(CrearUsuario(nuevoUsuario));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<UsuarioBloc, UsuarioState>(
        listener: (context, state) async {
          if (state is UsuarioError) {
            _mostrarError(state.mensaje);
          }
          if (state is UsuarioAutenticado) {
            await SessionService.saveUsuario(state.usuario);
            await SessionService.setFincasDelUsuario([]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CrearFincaPage()),
            );
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
                    'REGISTRARSE',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                      nombreController, 'Nombre completo', Icons.person),
                  const SizedBox(height: 20),
                  _buildTextField(
                      emailController, 'Correo electrónico', Icons.email),
                  const SizedBox(height: 20),
                  _buildPasswordField(passwordController, 'Contraseña', true),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                      confirmPasswordController, 'Confirmar Contraseña', false),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed:
                        state is UsuarioCargando ? null : _registrarUsuario,
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
                        : const Text('Registrarse'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Iniciar sesión',
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String label, bool isMain) {
    return TextField(
      controller: controller,
      obscureText: isMain ? !passwordVisible : !confirmPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isMain
                ? (passwordVisible ? Icons.visibility : Icons.visibility_off)
                : (confirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
            color: Colors.blueAccent,
          ),
          onPressed: () {
            setState(() {
              if (isMain) {
                passwordVisible = !passwordVisible;
              } else {
                confirmPasswordVisible = !confirmPasswordVisible;
              }
            });
          },
        ),
      ),
    );
  }
}
