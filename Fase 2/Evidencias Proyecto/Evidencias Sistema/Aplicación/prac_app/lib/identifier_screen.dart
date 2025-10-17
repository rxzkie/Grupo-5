// lib/identifier_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentifierScreen extends StatefulWidget {
  const IdentifierScreen({super.key});

  @override
  State<IdentifierScreen> createState() => _IdentifierScreenState();
}

class _IdentifierScreenState extends State<IdentifierScreen> {
  // Controlador para leer el texto del campo de texto
  final _aliasController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Cuando la pantalla se carga, intentamos leer el alias guardado
    _loadAlias();
  }

  // Función para cargar el alias guardado
  Future<void> _loadAlias() async {
    final prefs = await SharedPreferences.getInstance();
    // Leemos el string guardado con la clave 'user_alias'. Si no existe, usamos 'Usuario-Alpha'
    final savedAlias = prefs.getString('user_alias') ?? 'Usuario-Alpha';
    if (mounted) {
      setState(() {
        _aliasController.text = savedAlias;
        _isLoading = false;
      });
    }
  }

  // Función para guardar el nuevo alias
  Future<void> _saveAlias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_alias', _aliasController.text);
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Identificador')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Icon(Icons.account_circle, size: 100, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _aliasController, // Usamos el controlador
                    decoration: const InputDecoration(
                      labelText: 'Tu alias en la red',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // Al presionar, guardamos el alias
                      await _saveAlias();
                      if (mounted) {
                        // Mostramos una notificación de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Alias guardado!')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
    );
  }
}