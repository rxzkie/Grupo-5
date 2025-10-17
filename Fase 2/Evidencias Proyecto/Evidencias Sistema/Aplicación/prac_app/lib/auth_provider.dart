import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier que gestiona el estado de autenticación (true = logeado)
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Estado inicial (no logeado)

  void login() => state = true;
  void logout() => state = false;
}

// Provider que expone el AuthNotifier
final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);
