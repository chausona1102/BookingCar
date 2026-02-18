import 'package:flutter/material.dart';

class ActionItem {
  final String image;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ActionItem({
    required this.image,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
