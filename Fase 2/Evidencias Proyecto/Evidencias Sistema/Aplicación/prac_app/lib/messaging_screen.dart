// lib/messaging_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prac_app/ble_provider.dart';
import 'package:prac_app/database_helper.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  List<Message> _messages = [];
  final _textController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshMessages();
  }

  Future<void> _refreshMessages() async {
    try {
      final data = await DatabaseHelper.instance.getAllMessages().timeout(const Duration(seconds: 5));
      if (mounted) setState(() { _messages = data; _isLoading = false; });
    } catch (e) {
      debugPrint("Error al cargar mensajes: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;
    
    final bleState = ref.read(bleConnectionProvider);
    if (bleState.meshtasticCharacteristic == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.orange, content: Text('Primero conecta un nodo en "Estado de la Red".')));
      return;
    }

    try {
      final characteristic = bleState.meshtasticCharacteristic!;

      final textBytes = utf8.encode(_textController.text);
      
      // Construimos un paquete simplificado para enviar texto al canal por defecto.
      final destination = [0xff, 0xff, 0xff, 0xff]; // Destino: Broadcast
      final dataType = [0xdc]; // Tipo de Paquete: Data (texto)
      final packetId = [0x00, 0x00, 0x00, 0x00]; // ID de paquete (lo dejamos en 0)
      
      final fullPacket = [...destination, ...dataType, ...packetId, ...textBytes];
      
      await characteristic.write(fullPacket, withoutResponse: true);

      final newMessage = Message(text: _textController.text, isMe: true, time: DateTime.now());
      await DatabaseHelper.instance.createMessage(newMessage);
      _textController.clear();
      _refreshMessages();

    } catch (e) {
      debugPrint('Error al enviar mensaje por BLE: $e');
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Error al escribir el paquete.')));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajería Offline')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('Aún no hay mensajes.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        reverse: true,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _MessageBubble(
                            text: message.text,
                            isMe: message.isMe,
                            time: DateFormat('hh:mm a').format(message.time),
                          );
                        },
                      ),
          ),
          _TextInputArea(
            controller: _textController,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _TextInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  const _TextInputArea({required this.controller, required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: onSendMessage,
              color: Theme.of(context).colorScheme.primary,
              iconSize: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  const _MessageBubble({required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).colorScheme.primary : const Color(0xFF2d3b47),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}