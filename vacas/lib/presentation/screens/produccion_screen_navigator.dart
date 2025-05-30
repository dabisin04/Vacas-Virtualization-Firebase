import 'package:flutter/material.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/presentation/screens/screensnavigators/datos_generales.dart';
import 'package:vacas/presentation/screens/screensnavigators/inicio_page.dart';

class ProduccionScreenNavigator extends StatelessWidget {
  const ProduccionScreenNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Producción')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildMenuButton(
                        context,
                        icon: Icons.bar_chart,
                        label: 'Resumen de Producción',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const InicioPage()),
                          );
                        },
                      ),
                      _buildMenuButton(
                        context,
                        icon: Icons.info,
                        label: 'Datos Generales',
                        color: Colors.blueAccent,
                        onTap: () async {
                          final farmId =
                              await SessionService.getFincaSeleccionada();
                          if (farmId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('No hay una finca seleccionada')),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DatosGeneralesPage(farmId: farmId),
                            ),
                          );
                        },
                      ),

                      // Aquí puedes agregar más botones cuando tengas otras pantallas
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
