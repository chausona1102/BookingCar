// lib/services/paypal_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaypalService {
  static String get ip => dotenv.env['IP_ADDRESS'] ?? 'localhost';
  // URL server Node.js của bạn
  static String _baseUrl = 'http://$ip:3000/api/payment'; // Android emulator
  // static const String _baseUrl = 'http://localhost:5000/api/payment'; // iOS

  // Bước 1: Tạo order → lấy approvalUrl
  static Future<Map<String, dynamic>?> createOrder({
    required double amount,
    String currency = 'USD',
    String description = 'Payment',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount.toStringAsFixed(2),
          'currency': currency,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
        // { orderId: '...', approvalUrl: '...' }
      }
      return null;
    } catch (e) {
      print('PayPal createOrder error: $e');
      return null;
    }
  }

  // Bước 2: Capture sau khi user approve
  static Future<Map<String, dynamic>?> captureOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/capture/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
        // { transactionId, amount, status: 'COMPLETED', ... }
      }
      return null;
    } catch (e) {
      print('PayPal captureOrder error: $e');
      return null;
    }
  }
}
