import 'package:flutter/material.dart';

void snackBarLogger(BuildContext context, String title, String type) {
  late Color borderColor;
  late Color bgColor;
  late Color iconColor;
  late IconData icon;

  switch (type) {
    case 'success':
      borderColor = Colors.green.shade400;
      bgColor = Colors.green.shade50;
      iconColor = Colors.green.shade600;
      icon = Icons.check_circle_outline_rounded;
      break;
    case 'warning':
      borderColor = Colors.amber.shade400;
      bgColor = Colors.amber.shade50;
      iconColor = Colors.amber.shade700;
      icon = Icons.warning_amber_rounded;
      break;
    case 'error':
      borderColor = Colors.red.shade400;
      bgColor = Colors.red.shade50;
      iconColor = Colors.red.shade600;
      icon = Icons.cancel_outlined;
      break;
    default:
      borderColor = Colors.grey.shade400;
      bgColor = Colors.grey.shade50;
      iconColor = Colors.grey.shade600;
      icon = Icons.info_outline_rounded;
  }

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 4, color: borderColor),
                  const SizedBox(width: 12),
                  Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => entry.remove(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) entry.remove();
  });
}
