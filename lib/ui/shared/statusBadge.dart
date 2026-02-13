import 'package:flutter/material.dart';

Widget StatusBadge(String status) {
  Color bgColor;

  switch (status) {
    case 'pending':
      status = 'Đang chờ';
      bgColor = Colors.orange;
      break;
    case 'accepted':
      status = 'Tài xế đang đến';
      bgColor = Colors.blue;
      break;
    case 'completed':
      status = 'Hoàn thành';
      bgColor = Colors.green;
      break;
    case 'cancelled':
      status = 'Đã hủy';
      bgColor = Colors.red;
      break;
    case 'ontrip':
      status = 'Đang trong chuyến đi';
      bgColor = Colors.green;
      break;
    default:
      bgColor = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: TextStyle(
        fontSize: 16,
        color: bgColor,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
