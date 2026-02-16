import 'package:flutter/material.dart';

PreferredSizeWidget myAppBar(BuildContext context, String title) {
  double size = 50;
  final isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;
  if (isLandscape) {
    size = 40;
  }
  return AppBar(
    backgroundColor: Colors.green,
    toolbarHeight: size,
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
    ),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
}
