import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget svgButtonPro(
  String icon,
  String title,
  String color,
  bool isActive,
  String size,
  VoidCallback action,
) {
  final Color _color;
  final double _paddingY;
  final double _paddingX;
  final double _fontSize;
  switch (size) {
    case 'large':
      _paddingX = 16;
      _paddingY = 8;
      _fontSize = 20;
      break;
    case 'medium':
      _paddingX = 10;
      _paddingY = 5;
      _fontSize = 18;
      break;
    case 'small':
      _paddingX = 8;
      _paddingY = 4;
      _fontSize = 14;
      break;
    default:
      _paddingX = 8;
      _paddingY = 4;
      _fontSize = 16;
  }

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
      padding: EdgeInsets.symmetric(horizontal: _paddingX, vertical: _paddingY),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: _fontSize,
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
