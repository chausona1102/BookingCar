import 'dart:async';
import 'dart:io';

import 'package:booking_app/models/user.dart';
import 'package:booking_app/services/admin/user_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class UserAdminManager extends ChangeNotifier {
  final logger = Logger();
  final UserAdminService _userService = UserAdminService();

  Timer? _debounce;

  bool isMax = false;
  int maxLength = 0;

  List<User> users = [];
  List<User> _allUsers = [];

  Future<void> fetchUserLimit() async {
    _allUsers = await _userService.fetchUserLimit();
    users = _allUsers;
    notifyListeners();
  }

  Future<void> fetchMoreUser() async {
    final more = await _userService.fetchMoreUser();
    if (more.isNotEmpty) {
      _allUsers.addAll(more);
      users = _allUsers;
    } else {
      isMax = true;
      maxLength = userLength;
    }
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

  void sortUserByName(String type) {
    switch (type) {
      case 'asc':
        ascUserByName();
        break;
      case 'desc':
        descUserByName();
        break;
      default:
        ascUserByName();
    }
  }

  void ascUserByName() {
    users.sort((a, b) => a.fullName.compareTo(b.fullName));
    notifyListeners();
  }

  void descUserByName() {
    users.sort((a, b) => b.fullName.compareTo(a.fullName));
    notifyListeners();
  }

  void sortUserByDate(String type) {
    switch (type) {
      case 'asc':
        ascUserByDate();
        break;
      case 'desc':
        descUserByDate();
        break;
      default:
        ascUserByDate();
    }
  }

  void ascUserByDate() {
    users.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  void descUserByDate() {
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  int get userLength => _allUsers.length;
  bool get isMaxLength => isMax;
  int get getMaxLength => maxLength;
}
