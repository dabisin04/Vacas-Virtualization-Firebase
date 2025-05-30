import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_bloc.dart';
import 'package:vacas/application/bloc/usuario_finca/usuario_finca_event.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/presentation/screens/home_page.dart';
import 'package:vacas/presentation/screens/login_screen.dart';
import 'package:vacas/presentation/screens/seleccionar_finca_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    await Future.delayed(const Duration(seconds: 2)); // Simula splash

    final estaLogueado = await SessionService.isLoggedIn();
    if (!estaLogueado) {
      _irA(const LoginScreen());
      return;
    }

    final usuario = await SessionService.getUsuario();
    final fincaSeleccionada = await SessionService.getFincaSeleccionada();

    if (usuario == null) {
      _irA(const LoginScreen());
      return;
    }

    // 🔥 Cargar fincas del usuario y guardarlas en SessionService
    final usuarioFincaBloc = context.read<UsuarioFincaBloc>();
    usuarioFincaBloc.add(CargarFincasDelUsuario(usuario.id));

    // Esperar a que SessionService setee correctamente las fincas
    await Future.delayed(const Duration(milliseconds: 500));

    final fincas = await SessionService.getFincasDelUsuario();
    debugPrint('[SplashScreen] Fincas del usuario: $fincas');

    if (fincaSeleccionada == null || fincaSeleccionada.isEmpty) {
      _irA(SeleccionarFincaPage(fincaIds: fincas));
    } else {
      _irA(const Homescreen());
    }
  }

  void _irA(Widget pagina) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pagina),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text('Cargando datos de sesión...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
