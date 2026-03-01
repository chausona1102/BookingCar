import 'package:flutter/material.dart';

void snackBarLogger(BuildContext context, String title, String type) {
  late Color color;
  late String fileName;
  switch (type) {
    case 'success':
      fileName = 'turtle_success.png';
      color = Colors.green;
      break;
    case 'warning':
      fileName = 'turtle_warning.png';
      color = const Color.fromARGB(255, 231, 211, 28);
      break;
    case 'error':
      fileName = 'turtle_error.png';
      color = Colors.red;
      break;
  }

  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Row(
            children: [
              Image.asset('assets/images/$fileName', height: 70),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 3), () => entry.remove());
}
