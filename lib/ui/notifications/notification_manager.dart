import 'package:booking_app/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:booking_app/services/notification_service.dart';
// import 'package:logger/logger.dart';

class NotificationManager extends ChangeNotifier {
  final List<NotificationApp> _notifications = [];
  int _unreadCount = 0;
  List<NotificationApp> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  // final logger = Logger();
  Future<void> loadNotifications(String userId) async {
    final notis = await NotificationService().getNotificationsOfUser(userId);
    _notifications.clear();
    _notifications.addAll(notis);
    _unreadCount = notis.length;
    _unreadCount = 0;
    notifyListeners();
  }

 Future<void> addNotification(
    String title,
    String type,
    String message,
    String userId,
  ) async {
    final n = NotificationApp(
      title: title,
      type: type,
      userId: userId,
      message: message,
    );
    await NotificationService().insertNotification(n);
    _notifications.insert(0, n);
    _unreadCount++;
    notifyListeners();
  }

Future<bool> removeNotificationById(String id, String userId) async {
    final result = await NotificationService().removeNotificationById(id);
    return result;
  }

  void clearAll(String userId) async {
    _notifications.clear();
    _unreadCount = 0;
    await NotificationService().removeAllNotificationOfUser(userId);
    notifyListeners();
  }

  List<NotificationApp> notificationsOfUser(String userId) {
    return _notifications.where((n) => n.userId == userId).toList();
  }
}
