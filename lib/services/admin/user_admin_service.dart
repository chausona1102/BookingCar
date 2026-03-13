import 'dart:io';

import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';
import '../pb_client.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class UserAdminService {
  PocketBase get pb => pocketBase;
  final logger = Logger();

  var page = 1;
  Future<List<User>> fetchUserLimit() async {
    logger.i('Fetching Users....');
    page = 1;
    try {
      final records = await pb
          .collection('users')
          .getList(page: page, perPage: 20, filter: 'role != "admin"');
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

  Future<List<User>> fetchMoreUser() async {
    page++;
    try {
      final records = await pb
          .collection('users')
          .getList(page: page, perPage: 20, filter: 'role != "admin"');
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

  Future<bool> deleteUserById(BuildContext context, String id) async {
    logger.i('Deleting "$id"...');
    try {
      await pb.collection('users').delete(id);
      return true;
    } on ClientException catch (e) {
      final data = e.response;
      final message = data['message'];
      if (message ==
          'Failed to delete record. Make sure that the record is not part of a required relation reference.') {
        snackBarLogger(context, 'Không thể xóa! Xóa tài xế trước', 'warning');
      } else {
        snackBarLogger(context, 'Không thể xóa!', 'warning');
      }
      return false;
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

  Future<List<User>?> search(String key) async {
    try {
      final records = await pb
          .collection('users')
          .getList(
            filter:
                'id ~ "$key" || username ~ "$key" || firstname ~ "$key" || lastname ~ "$key"',
          );
      return records.items.map((e) {
        final json = e.toJson();
        json['id'] = e.id;
        return User.fromJson(json);
      }).toList();
    } catch (e) {
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
