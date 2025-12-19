import 'dart:io';

import 'package:booking_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';

class AuthManager extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  // bool? get isLoggedIn => _authService.isLoggedIn;
  bool get isLoggedIn => _user != null;
  User? get user => _user;
  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    print('ket qua dang nhap: $success');
    if (success) {
      _user = _authService.currentUser;
      notifyListeners();
    }
    return success;
  }

  void restoreLogin() {
    if (_authService.isLoggedIn) {
      _user = _authService.currentUser;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String username,
    required String firstname,
    required String lastname,
    required String phone,
    required String password,
    required String passwordConfirm,
    File? avatar,
  }) async {
    if (password != passwordConfirm) {
      throw Exception("Mật khẩu không khớp");
    }
    return await _authService.register(
      email: email,
      username: username,
      firstname: firstname,
      lastname: lastname,
      phone: phone,
      password: password,
      avatar: avatar,
    );
  }

  User? get currentUser => _authService.currentUser;
  static String? currentUserId() {
    return AuthService().currentUser?.id;
  }
}
