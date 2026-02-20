import 'package:flutter/material.dart';

Widget textFieldForm(
  TextEditingController controler,
  String title,
  IconData icon,
  bool disable,
) {
  return TextField(
    enabled: !disable,
    cursorColor: Colors.green,
    cursorErrorColor: Colors.red,
    controller: controler,
    decoration: InputDecoration(
      labelText: title,
      labelStyle: TextStyle(color: Colors.black38),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black38),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1),
      ),
      prefixIcon: Icon(icon, color: Colors.green),
    ),
  );
}
