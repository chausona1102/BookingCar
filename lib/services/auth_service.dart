import 'package:booking_app/ui/shared/showDialogNotif.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/user.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'pb_client.dart';

class AuthService extends ChangeNotifier {
  PocketBase get pb => pocketBase;
  final logger = Logger();
  Future<bool> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    logger.i(pb.baseURL);
    try {
      await pb.collection('users').authWithPassword(username, password);
      if (!await checkIsActive(username)) {
        showMyDialogNoti(
          // ignore: use_build_context_synchronously
          context,
          'Thông báo từ hệ thống',
          'Tài khoản đã bị khóa',
        );
        return false;
      }
      notifyListeners();
      return pb.authStore.isValid;
    } on ClientException catch (e) {
      final data = e.response;
      logger.i(data);
      return false;
    }
  }

  Future<bool> checkIsActive(String username) async {
    try {
      final user = await pb
          .collection('users')
          .getFirstListItem('username = "$username"');
      return user.data['isactive'];
    } on ClientException catch (e) {
      logger.i(e.response);
      return false;
    }
  }

  Future<bool> updatePassword({
    required String id,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await pb
          .collection('users')
          .update(
            id,
            body: {
              'oldPassword': oldPassword,
              'password': newPassword,
              'passwordConfirm': newPassword,
            },
          );
      return true;
    } on ClientException catch (e) {
      logger.i('Lỗi đổi mật khẩu: ${e.response}');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String firstname,
    required String lastname,
    required String phone,
    required String password,
    File? avatar,
  }) async {
    try {
      final body = {
        'email': email,
        'username': username,
        'emailVisibility': true,
        'firstname': firstname,
        'lastname': lastname,
        'phone': phone,
        'role': 'customer',
        'password': password,
        'passwordConfirm': password,
        'isactive': true,
      };
      final files = <http.MultipartFile>[];
      if (avatar != null) {
        files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
      }

      await pb.collection('users').create(body: body, files: files);
      return true;
    } on ClientException catch (e) {
      final data = e.response['data'];
      logger.i(data);
      if (data != null && data['email'] != null) {
        final fieldName = data.keys.first;
        final error = data[fieldName]['message'];
        if (error == 'Value must be unique.') {
          throw ('Email đã tồn tại');
        }
      } else if (data != null && data['username'] != null) {
        final fieldName = data.keys.first;
        final error = data[fieldName]['message'];
        if (error == 'Value must be unique.') {
          throw ('Tài khoản đã tồn tại');
        }
      }

      throw e.response['message'] ?? 'Đăng ký thất bại';
    }
  }

  Future<User?> update({
    required String id,
    required String firstname,
    required String lastname,
    required String phone,
    File? avatar,
  }) async {
    try {
      final body = {
        'firstname': firstname,
        'lastname': lastname,
        'phone': phone,
      };

      RecordModel record;

      if (avatar != null) {
        record = await pb
            .collection('users')
            .update(
              id,
              body: body,
              files: [await http.MultipartFile.fromPath('avatar', avatar.path)],
            );
      } else {
        record = await pb.collection('users').update(id, body: body);
      }

      pb.authStore.save(pb.authStore.token, record);

      return User.fromJson(record.toJson());
    } catch (e) {
      logger.i('Lỗi update: $e');
      return null;
    }
  }

  Future<bool> toggleActive(String id) async {
    try {
      final record = await pb.collection('users').getOne(id);
      final currentActive = record.data['isactive'] as bool;

      await pb
          .collection('users')
          .update(id, body: {'isactive': !currentActive});
      return true;
    } on ClientException catch (e) {
      final data = e.response;
      logger.i(data);
      return false;
    }
  }

  Future<void> logout() async {
    pb.authStore.clear();
  }

  bool get isLoggedIn => pb.authStore.isValid && pb.authStore.token.isNotEmpty;
  User? get currentUser {
    final record = pb.authStore.record;
    if (record == null) return null;
    return User.fromJson(record.toJson());
  }

  String? get userId => pb.authStore.model?.id;
}
