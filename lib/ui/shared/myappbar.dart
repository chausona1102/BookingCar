import 'package:flutter/material.dart';

PreferredSizeWidget myAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.green,
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
    ),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
}
