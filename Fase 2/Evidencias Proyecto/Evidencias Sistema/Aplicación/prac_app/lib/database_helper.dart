// lib/database_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Modelo de datos para un Mensaje
class Message {
  final int? id;
  final String text;
  final bool isMe;
  final DateTime time;

  Message({this.id, required this.text, required this.isMe, required this.time});

  // Convierte un Map a un objeto Message
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      text: map['text'],
      isMe: map['isMe'] == 1,
      time: DateTime.parse(map['time']),
    );
  }

  // Convierte un objeto Message a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isMe': isMe ? 1 : 0,
      'time': time.toIso8601String(),
    };
  }
}

class DatabaseHelper {
  // Hacemos la clase un Singleton para tener una única instancia
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prac_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Crea la tabla de mensajes
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        isMe INTEGER NOT NULL,
        time TEXT NOT NULL
      )
    ''');
  }

  // Inserta un nuevo mensaje
  Future<Message> createMessage(Message message) async {
    final db = await instance.database;
    final id = await db.insert('messages', message.toMap());
    return Message(id: id, text: message.text, isMe: message.isMe, time: message.time);
  }

  // Obtiene todos los mensajes, ordenados por fecha
  Future<List<Message>> getAllMessages() async {
    final db = await instance.database;
    final result = await db.query('messages', orderBy: 'time DESC');
    return result.map((json) => Message.fromMap(json)).toList();
  }

  // Cierra la base de datos
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}