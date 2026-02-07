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
}
