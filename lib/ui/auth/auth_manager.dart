import 'dart:async';
import 'dart:io';

import 'package:booking_app/services/auth_service.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import '../../models/user.dart';

class AuthManager extends ChangeNotifier {
  bool isRestored = false;
  Completer<void> _completer = Completer();
  Future<void> get restoredFuture => _completer.future;
  final logger = Logger();
  final AuthService _authService = AuthService();
  User? _user;
  // bool? get isLoggedIn => _authService.isLoggedIn;
  bool get isLoggedIn => _user != null;
  User? get user => _user;
  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      _user = _authService.currentUser;
      notifyListeners();
    }
    return success;
  }

  Future<bool> verify(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_user == null) return false;
    final success = await _authService.updatePassword(
      id: _user!.id,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    return success;
  }

  Future<void> restoreLogin() async {
    if (_authService.isLoggedIn) {
      _user = _authService.currentUser;
      notifyListeners();
    }

    isRestored = true;
    _completer.complete();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> register({
    required BuildContext context,
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
      snackBarLogger(context, "Mật khẩu không khớp", 'warning');
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

  Future<bool> update({
    required String id,
    required String firstname,
    required String lastname,
    required String phone,
    File? avatar,
  }) async {
    if (_user == null) {
      logger.i('User undefined: AuthManager.update()');
      return false;
    }
    ;
    final updatedUser = await _authService.update(
      id: id,
      firstname: firstname,
      lastname: lastname,
      phone: phone,
      avatar: avatar,
    );
    if (updatedUser != null) {
      _user = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  User? get currentUser => _authService.currentUser;
  String? get role => _user?.role;
  bool? get active => _user?.isActive;
  // static String? currentUserId() {
  //   return AuthService().currentUser?.id;
  // }
  String? get currentUserId => _authService.userId;
}
