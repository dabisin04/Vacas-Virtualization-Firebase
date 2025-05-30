import 'package:flutter/material.dart';
import 'package:vacas/core/services/session_service.dart';
import 'package:vacas/presentation/screens/reproduccion_tab.dart';
import 'package:vacas/presentation/screens/screensnavigators/inicio_page.dart';
import 'package:vacas/presentation/screens/screensnavigators/animals_page.dart';
import 'custom_drawer.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  ///  farmId de la finca actualmente activa (se establece en initState)
  String? _farmId;

  @override
  void initState() {
    super.initState();
    _initFarmId();
  }

  Future<void> _initFarmId() async {
    final id = await SessionService.getFincaSeleccionada();
    if (!mounted) return;
    setState(() => _farmId = id);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_farmId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Finca'),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: const [
          InicioPage(), // sin parámetros
          AnimalesPage(), // sin parámetros
          ReproduccionTab(), // NUEVO wrapper
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Animales'),
          BottomNavigationBarItem(
              icon: Icon(Icons.family_restroom), label: 'Reproducción'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
