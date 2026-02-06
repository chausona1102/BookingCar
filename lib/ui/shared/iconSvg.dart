import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget svgIcon(String icon, String color) {
  Color _color;
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

  return SvgPicture.asset(
    icon,
    height: 24,
    width: 24,
    colorFilter: ColorFilter.mode(_color, BlendMode.srcIn),
  );
}
