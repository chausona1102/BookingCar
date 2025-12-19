import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/user.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  late final PocketBase pb;
  factory AuthService() => _instance;

  AuthService._internal() {
    final url = dotenv.env['POCKETBASE_URL'] ?? 'http://10.0.2.2:8090';
    pb = PocketBase(url);
  }
  Future<bool> login(String username, String password) async {
    try {
      await pb.collection('users').authWithPassword(username, password);
      notifyListeners();
      return pb.authStore.isValid;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
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
    } catch (e) {
      print('Lỗi đăng ký: $e');
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
}
