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
    default:
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      content: Row(
        children: [
          Image.asset('assets/images/$fileName', height: 70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: TextStyle(color: color, fontSize: 18)),
          ),
        ],
      ),
    ),
  );
}
