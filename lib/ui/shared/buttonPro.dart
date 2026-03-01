import 'package:flutter/material.dart';

Widget buttonPro(
  String title,
  String type,
  VoidCallback action, {
  bool filled = false,
}) {
  final configs = {
    'success': (Color(0xFF22C97A), Colors.transparent),
    'warning': (Color(0xFFF5C542), Colors.transparent),
    'error': (Color(0xFFF04B5E), Colors.transparent),
    'normal': (Color(0xFFE8E8F0), Colors.transparent),
    'light': (Color(0xFFFFFFFF), Color(0xFFFFFFFF)),
  };

  final (borderColor, bgColor) =
      configs[type] ?? (Color(0xFF22C97A), Colors.transparent);
  final textColor = (type == 'light') ? Colors.black87 : borderColor;
  final fillColor = filled ? borderColor.withOpacity(0.12) : bgColor;

  return TextButton(
    onPressed: action,
    style: TextButton.styleFrom(
      foregroundColor: textColor,
      backgroundColor: fillColor,
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 1),
      ),
      textStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    child: Text(title),
  );
}
