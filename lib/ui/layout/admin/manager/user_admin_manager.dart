import 'dart:async';
import 'dart:io';

import 'package:booking_app/models/user.dart';
import 'package:booking_app/services/admin/user_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class UserAdminManager extends ChangeNotifier {
  final logger = Logger();
  final UserService _userService = UserService();

  Timer? _debounce;

  List<User> users = [];

  Future<void> fetchUserLimit() async {
    users = await _userService.fetchUserLimit();
    notifyListeners();
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

  Future<bool> deleteUserById(BuildContext context, String id) async {
    return await _userService.deleteUserById(context, id);
  }

  Future<bool> toggleIsActive(String id) async {
    final success = await _userService.toggleActive(id);
    if (!success) {
      return false;
    }
    final index = users.indexWhere((r) => r.id == id);
    if (index != -1) {
      users[index].isActive = !users[index].isActive;
      notifyListeners();
    }
    return true;
  }

  Future<void> search(String key) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final result = await _userService.search(key);
      users = result ?? [];
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
