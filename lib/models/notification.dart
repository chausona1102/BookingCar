import 'package:intl/intl.dart';

class NotificationApp {
  final int? id;
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
