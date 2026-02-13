import 'package:booking_app/models/membership.dart';
import 'package:booking_app/models/user.dart';
import 'package:flutter/material.dart';

class BannerItem {
  final String image;
  final void Function(BuildContext context, Membership? membership, User? user)
  onTap;

  BannerItem({required this.image, required this.onTap});
}
