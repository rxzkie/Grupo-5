// lib/map_screen.dart
import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Alertas (Online)')),
      body: const Center(
        child: Text('Aquí se mostraría el mapa interactivo.'),
      ),
    );
  }
}