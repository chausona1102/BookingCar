import 'dart:io';

import 'package:booking_app/models/user.dart';
import 'package:booking_app/services/admin/user_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class UserAdminManager extends ChangeNotifier {
  final logger = Logger();
  final UserService _userService = UserService();

  List<User> users = [];

  Future<List<User>> fetchUserLimit() async {
    users = await _userService.fetchUserLimit();
    notifyListeners();
    return users;
  }

  Future<bool> update({
    required String id,
    required String firstname,
    required String lastname,
    required String phone,
    required String username,
    required String email,
    File? avatar,
  }) async {
    try {
      final success = await _userService.update(
        id: id,
        firstname: firstname,
        lastname: lastname,
        username: username,
        email: email,
        phone: phone,
        avatar: avatar,
      );
      if (success) {
        await fetchUserLimit();
      }
      return success;
    } catch (e) {
      logger.i(e);
      return false;
    }
  }
}
