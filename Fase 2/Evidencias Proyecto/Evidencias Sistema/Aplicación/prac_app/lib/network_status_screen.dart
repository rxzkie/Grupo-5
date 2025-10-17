// lib/network_status_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prac_app/ble_provider.dart';

class NetworkStatusScreen extends ConsumerStatefulWidget {
  const NetworkStatusScreen({super.key});

  @override
  ConsumerState<NetworkStatusScreen> createState() => _NetworkStatusScreenState();
}

class _NetworkStatusScreenState extends ConsumerState<NetworkStatusScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  void _toggleScan() {
    if (mounted) setState(() => _isScanning = !_isScanning);

    if (_isScanning) {
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        final uniqueResults = {for (var r in results) r.device.remoteId: r};
        if (mounted) setState(() => _scanResults = uniqueResults.values.toList());
      }, onError: (e) => debugPrint('Error en escaneo: $e'));
      
      // --- CORRECCIÓN CLAVE AQUÍ ---
      // Le decimos al navegador qué servicio nos interesa para evitar el error de seguridad.
      FlutterBluePlus.startScan(
        withServices: [Guid("6ba1b218-15a8-461f-9fa8-5dcae273eafd")],
        timeout: const Duration(seconds: 30),
      );
    } else {
      FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
    }
  }

  void _connectToDevice(BluetoothDevice device) {
    ref.read(bleConnectionProvider.notifier).connectToDevice(device);
    if (mounted) setState(() => _isScanning = false);
    FlutterBluePlus.stopScan();
  }

  void _disconnectFromDevice() {
    ref.read(bleConnectionProvider.notifier).disconnectFromDevice();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleConnectionProvider);
    final connectedDevice = bleState.connectedDevice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de la Red'),
        actions: [
          TextButton(
            onPressed: _toggleScan,
            child: Text(
              _isScanning ? 'Detener' : 'Buscar Nodos',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          )
        ],
      ),
      body: connectedDevice != null
          ? _buildConnectedView(connectedDevice)
          : _buildScannerView(bleState.isConnecting),
    );
  }

  Widget _buildScannerView(bool isConnecting) {
    return ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        final result = _scanResults[index];
        if (result.device.platformName.isNotEmpty) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.router),
              title: Text(result.device.platformName),
              subtitle: Text(result.device.remoteId.toString()),
              trailing: ElevatedButton(
                onPressed: isConnecting ? null : () => _connectToDevice(result.device),
                child: isConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Conectar'),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildConnectedView(BluetoothDevice device) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✓', style: TextStyle(fontSize: 80, color: Colors.green)),
          const SizedBox(height: 16),
          Text('Conectado a:', style: Theme.of(context).textTheme.headlineSmall),
          Text(device.platformName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _disconnectFromDevice, child: const Text('Desconectar')),
        ],
      ),
    );
  }
}