import 'package:flutter/material.dart';

Widget textField(String title, IconData icon, bool disable) {
  return TextField(
    enabled: !disable,
    cursorColor: Colors.green,
    cursorErrorColor: Colors.red,
    decoration: InputDecoration(
      labelText: title,
      labelStyle: const TextStyle(color: Colors.black38),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black38),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black38),
      ),
      prefixIcon: Icon(icon, color: disable ? Colors.black38 : Colors.green),
    ),
  );
}
