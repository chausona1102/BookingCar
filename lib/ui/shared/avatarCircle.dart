import 'package:booking_app/models/user.dart';
import 'package:flutter/material.dart';

Widget avatarCircle(User user, double radius) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.white,
    backgroundImage: user.avatarUrl != null
        ? NetworkImage(user.avatarUrl!)
        : const AssetImage('assets/default_avatar.png') as ImageProvider,
  );
}
