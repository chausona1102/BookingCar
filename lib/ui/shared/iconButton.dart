import 'package:flutter/material.dart';

Widget iconButton({
  required String imagePath,
  required String text,
  required String size,
}) {
  double _size = 60;
  double _fontSize = 16;
  switch (size) {
    case 'small':
      _fontSize = 14;
      _size = 60;
      break;
    case 'medium':
      _fontSize = 16;
      _size = 80;
      break;
    case 'large':
      _fontSize = 20;
      _size = 100;
      break;
    default:
      _fontSize = 14;
      _size = 60;
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(imagePath, width: _size, height: _size, fit: BoxFit.contain),
      Text(
        text,
        style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
