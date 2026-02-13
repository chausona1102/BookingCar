import 'package:flutter/material.dart';

Future<bool?> showMyDialog(
  BuildContext context,
  String title,
  String message,
  String icon,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon.isNotEmpty) ...[
            Image.asset(icon, height: 70),
            const SizedBox(height: 8),
          ],
          Text(title, textAlign: TextAlign.center),
        ],
      ),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Không'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Có', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
