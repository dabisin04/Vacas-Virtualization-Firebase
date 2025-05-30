import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/custom_drawer.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: CustomDrawer(),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
