// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prac_app/auth_provider.dart';
import 'package:prac_app/home_screen.dart';
import 'package:prac_app/login_screen.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de cualquier otra cosa
  WidgetsFlutterBinding.ensureInitialized();

  // Esta condición revisa si la aplicación está corriendo en un navegador web
  if (kIsWeb) {
    // Si es web, le decimos a sqflite que use el "driver" o "adaptador" para web
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Envolvemos la aplicación en un ProviderScope para que Riverpod funcione
  runApp(const ProviderScope(child: MyApp()));
}

// MyApp ahora "escucha" los cambios de estado de los providers
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() "espía" el estado de authProvider.
    // Si cambia, reconstruye este widget.
    final isLoggedIn = ref.watch(authProvider);

    return MaterialApp(
      title: 'PRAC App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2596be),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1a2127),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Lógica principal: si el usuario está logueado, va a HomePage.
      // Si no, va a LoginPage.
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}