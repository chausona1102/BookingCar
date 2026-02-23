import 'package:flutter/material.dart';

Future<bool?> showMyDialogNoti(
  BuildContext context,
  String title,
  String message,
) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(title, textAlign: TextAlign.center)],
      ),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ok', style: TextStyle(color: Colors.green)),
          ),
        ),
      ],
    ),
  );
}
