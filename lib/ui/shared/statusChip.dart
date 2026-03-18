import 'package:flutter/material.dart';

Widget statusChip(String status) {
  final Map<String, (String, Color)> statusMap = {
    'pending': ('Chờ xác nhận', Colors.orange),
    'accepted': ('Đã xác nhận', Colors.blue),
    'ontrip': ('Đang trong chuyến', const Color.fromARGB(255, 33, 243, 243)),
    'completed': ('Hoàn thành', Colors.green),
    'cancelled': ('Đã huỷ', Colors.red),
  };

  final (label, color) = statusMap[status] ?? (status, Colors.grey);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
    ),
  );
}
