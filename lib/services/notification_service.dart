import 'package:sqflite/sqflite.dart';
import '../models/notification.dart';
import 'package:path/path.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notifications_bookingapp.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            type TEXT,
            userId TEXT,
            message TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> insertNotification(NotificationApp n) async {
    final db = await database;
    await db.insert('notifications', {
      'title': n.title,
      'type': n.type,
      'userId': n.userId,
      'message': n.message,
      'createdAt': n.createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NotificationApp>> getNotificationsOfUser(String userId) async {
    final db = await database;
    final result = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return result
        .map(
          (e) => NotificationApp(
            id: e['id'] as int,
            title: e['title'] as String,
            type: e['type'] as String,
            userId: e['userId'] as String,
            message: e['message'] as String,
            createdAt: DateTime.parse(e['createdAt'] as String),
          ),
        )
        .toList();
  }

  Future<bool> removeNotificationById(int id, String userId) async {
    final db = await database;
    final count = await db.delete(
      'notifications',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
    return count > 0;
  }

  Future<void> removeAllNotificationOfUser(String userId) async {
    final db = await database;
    await db.delete('notifications', where: 'userId = ?', whereArgs: [userId]);
  }
}
