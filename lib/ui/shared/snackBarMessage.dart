import 'package:flutter/material.dart';

void snackBarMessage(BuildContext context, String title, String type) {
  Color bgColors;
  switch (type) {
    case 'success':
      bgColors = Color(0xFF00C853);
      break;
    case 'error':
      bgColors = Colors.redAccent;
      break;
    case 'warning':
      bgColors = Colors.yellow.shade600;
      break;
    default:
      bgColors = Color(0xFF00C853);
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      backgroundColor: bgColors,
    ),
  );
}
