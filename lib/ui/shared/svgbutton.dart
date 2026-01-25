import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget svgButton(String icon, String type, VoidCallback action) {
  final Color color = type == 'light' ? Colors.white : Colors.black;

  return InkWell(
    onTap: action,
    child: SvgPicture.asset(
      icon,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    ),
  );
}
