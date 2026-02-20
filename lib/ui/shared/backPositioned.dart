import 'package:flutter/material.dart';

Widget backPositioned(BuildContext context) {
  return Positioned(
    top: 50,
    left: 20,
    height: 70,
    width: 70,
    child: GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
    ),
  );
}
