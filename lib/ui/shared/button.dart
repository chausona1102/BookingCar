import 'package:flutter/material.dart';

Widget button(String title, type, action) {
  var color;
  var fill;
  switch (type) {
    case 'success':
      fill = Colors.green;
      color = Colors.green;
      break;
    case 'warning':
      fill = Colors.yellow;
      color = Colors.black;
      break;
    case 'error':
      fill = Colors.red;
      color = Colors.red;
      break;
    case 'normal':
      fill = Colors.black;
      color = Colors.black;
    case 'light':
      fill = Colors.white;
      color = Colors.white;
  }
  return TextButton(
    onPressed: action,
    style: TextButton.styleFrom(
      foregroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: fill),
    ),
    child: Text(title),
  );
}
