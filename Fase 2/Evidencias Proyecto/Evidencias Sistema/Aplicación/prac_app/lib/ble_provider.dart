// lib/ble_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BleConnectionState {
  final BluetoothDevice? connectedDevice;
  final bool isConnecting;
  final BluetoothCharacteristic? meshtasticCharacteristic;

  const BleConnectionState({
    this.connectedDevice,
    this.isConnecting = false,
    this.meshtasticCharacteristic,
  });
}

class BleConnectionNotifier extends StateNotifier<BleConnectionState> {
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  BleConnectionNotifier() : super(const BleConnectionState());

  Future<void> connectToDevice(BluetoothDevice device) async {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen((connectionState) {
      if (connectionState == BluetoothConnectionState.disconnected) {
        state = const BleConnectionState();
      }
    });

    try {
      state = const BleConnectionState(isConnecting: true);
      await device.connect(autoConnect: false);

      if (!kIsWeb) {
        await device.requestMtu(512);
      }

      List<BluetoothService> services = await device.discoverServices();
      final service = services.firstWhere((s) => s.uuid.toString() == '6ba1b218-15a8-461f-9fa8-5dcae273eafd');

      // --- CORRECCIÓN FINAL AQUÍ ---
      // Usamos el UUID correcto que encontramos en la consola de depuración.
      final characteristic = service.characteristics.firstWhere((c) => c.uuid.toString() == 'f75c76d2-129e-4dad-a1dd-7866124401e7');
      
      state = BleConnectionState(
        connectedDevice: device,
        isConnecting: false,
        meshtasticCharacteristic: characteristic,
      );
      debugPrint('✅ Dispositivo conectado y servicio encontrado!');
    } catch (e) {
      state = const BleConnectionState(isConnecting: false);
      debugPrint('❌ Error al conectar o descubrir servicios: $e');
      try { await device.disconnect(); } catch (_) {}
    }
  }

  Future<void> disconnectFromDevice() async {
    try { await state.connectedDevice?.disconnect(); } catch (e) { debugPrint('⚠️ Error al desconectar: $e'); }
    state = const BleConnectionState();
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    super.dispose();
  }
}

final bleConnectionProvider = StateNotifierProvider<BleConnectionNotifier, BleConnectionState>((ref) {
  return BleConnectionNotifier();
});