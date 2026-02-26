import 'package:intl/intl.dart';

class NotificationApp {
  final String? id;
  final String title;
  final String type;
  final String userId;
  final String message;
  final DateTime createdAt;

  NotificationApp({
    this.id,
    required this.title,
    required this.type,
    required this.userId,
    required this.message,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationApp.fromJson(Map<String, dynamic> json) {
    return NotificationApp(
      id: json['_id'],
      title: json['title'],
      type: json['type'],
      userId: json['userId'],
      message: json['message'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String get timeFormatted {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toLocal());
  }

  String get timeDate {
    return DateFormat('dd/MM/yyyy').format(createdAt.toLocal());
  }

  String get timeHour {
    return DateFormat('HH:mm').format(createdAt.toLocal());
  }
}
