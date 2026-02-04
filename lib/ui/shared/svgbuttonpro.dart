import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget svgButtonPro(
  String icon,
  String title,
  String color,
  bool isActive,
  VoidCallback action,
) {
  final Color _color;
  switch (color) {
    case 'light':
      _color = Colors.white;
      break;
    case 'dart':
      _color = Colors.black;
      break;
    case 'dart45':
      _color = Colors.black45;
      break;
    case 'green':
      _color = Colors.green;
      break;
    default:
      _color = Colors.black;
  }
  final Color _borderColor = isActive ? Colors.green : _color;
  final Color _textColor = isActive ? Colors.green : _color;
  return InkWell(
    onTap: action,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _textColor,
            ),
          ),
          const SizedBox(width: 5),
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(_textColor, BlendMode.srcIn),
          ),
        ],
      ),
    ),
  );
}
