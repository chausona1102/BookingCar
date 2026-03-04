import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationService {
  static const String baseUrl = 'http://10.10.112.109:3000/api/notifications';
  Future<List<NotificationApp>> getNotificationsOfUser(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => NotificationApp.fromJson(e)).toList();
    }
    throw Exception('Lỗi khi lấy thông báo');
  }

  Future<void> insertNotification(NotificationApp n) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': n.title,
        'type': n.type,
        'userId': n.userId,
        'message': n.message,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi khi tạo thông báo');
    }
  }

  Future<bool> removeNotificationById(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }

  Future<void> removeAllNotificationOfUser(String userId) async {
    await http.delete(Uri.parse('$baseUrl/user/$userId'));
  }
}
