import 'package:flutter/material.dart';

class BannerItem {
  final String image;
  final void Function(BuildContext context) onTap;

  BannerItem({required this.image, required this.onTap});
}
