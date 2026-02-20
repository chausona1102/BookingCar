import 'package:flutter/material.dart';

PreferredSizeWidget myAppBar(BuildContext context, String title) {
  final isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;
  return AppBar(
    backgroundColor: Colors.green,
    toolbarHeight: isLandscape ? MediaQuery.of(context).size.height * 0.1 : 50,
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
