import 'dart:io';

import 'package:booking_app/models/user.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';
import '../pb_client.dart';
import 'package:http/http.dart' as http;

class UserService {
  PocketBase get pb => pocketBase;
  final logger = Logger();

  Future<List<User>> fetchUserLimit() async {
    logger.i('Fetching....');
    try {
      final records = await pb
          .collection('users')
          .getList(page: 1, perPage: 20, filter: 'role != "admin"');
      return records.items.map((r) {
        final json = r.toJson();
        json['id'] = r.id;
        return User.fromJson(json);
      }).toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<bool> update({
    required String id,
    required String firstname,
    required String lastname,
    required String username,
    required String email,
    required String phone,
    File? avatar,
  }) async {
    try {
      final body = {
        'firstname': firstname,
        'lastname': lastname,
        'username': username,
        'email': email,
        'phone': phone,
        'isactive': true,
      };

      if (avatar != null) {
        await pb
            .collection('users')
            .update(
              id,
              body: body,
              files: [await http.MultipartFile.fromPath('avatar', avatar.path)],
            );
      } else {
        await pb.collection('users').update(id, body: body);
      }

      return true;
    } catch (e) {
      logger.e('Lỗi update: $e');
      return false;
    }
  }
}
