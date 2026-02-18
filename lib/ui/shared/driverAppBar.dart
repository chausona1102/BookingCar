import 'package:flutter/material.dart';

PreferredSizeWidget driverAppBar(String title) {
  return AppBar(
    backgroundColor: const Color(0xFF0F1923),
    foregroundColor: Colors.white,
    elevation: 0,
    title: Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
  );
}
