// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importamos Riverpod
import 'package:prac_app/auth_provider.dart';
import 'package:prac_app/identifier_screen.dart';
import 'package:prac_app/map_screen.dart';
import 'package:prac_app/messaging_screen.dart';
import 'package:prac_app/network_status_screen.dart';

// 2. Convertimos a ConsumerWidget para poder usar 'ref'
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // 3. Añadimos WidgetRef ref
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF1a2127),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF0c1217)),
                child: Center(
                    child: Image.asset('assets/logo_app.png', height: 60)),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.white),
                title: const Text('Panel de Control',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.white),
                title: const Text('Mapa de Alertas (Online)',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MapScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.network_check, color: Colors.white),
                title: const Text('Estado de la Red',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NetworkStatusScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.badge, color: Colors.white),
                title: const Text('Mi Identificador',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IdentifierScreen()));
                },
              ),
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Cerrar Sesión',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  // 4. ¡Magia! Le decimos al authProvider que cierre sesión.
                  ref.read(authProvider.notifier).logout();
                  // Ya no necesitamos la navegación manual.
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context: context,
              icon: Icons.message,
              title: 'Mensajería\nOffline',
              destinationScreen: const MessagingScreen(),
            ),
            _buildDashboardCard(
              context: context,
              icon: Icons.map,
              title: 'Mapa de Alertas\n(Online)',
              destinationScreen: const MapScreen(),
            ),
            _buildDashboardCard(
              context: context,
              icon: Icons.network_check,
              title: 'Estado de\nla Red',
              destinationScreen: const NetworkStatusScreen(),
            ),
            _buildDashboardCard(
              context: context,
              icon: Icons.badge,
              title: 'Mi\nIdentificador',
              destinationScreen: const IdentifierScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget destinationScreen,
  }) {
    return Card(
      elevation: 4.0,
      color: const Color(0xFF2d3b47),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destinationScreen));
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white70),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}