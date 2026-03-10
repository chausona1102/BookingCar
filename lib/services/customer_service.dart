import 'package:booking_app/models/driverrequest.dart';
import 'package:booking_app/models/membership.dart';
import 'package:booking_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'pb_client.dart';

class CustomerService extends ChangeNotifier {
  PocketBase get pb => pocketBase;

  Future<bool> addDriverRequest({
    required String licensenumber,
    required String typecar,
    required String user,
    required String carnumber,
    File? carimage,
  }) async {
    // print(pb.authStore.isValid);
    // print(pb.authStore.model?.id);
    try {
      final body = {
        'licensenumber': licensenumber,
        'typecar': typecar,
        'user': user,
        'carnumber': carnumber,
        'status': 'requested',
      };
      // final roleChange = await changeRole(user: user);
      // if (!roleChange) return false;
      final files = <http.MultipartFile>[];
      if (carimage != null) {
        files.add(await http.MultipartFile.fromPath('carimage', carimage.path));
      }
      await pb.collection('driverrequests').create(body: body, files: files);
      return true;
    } catch (e) {
      // await pb.collection('users').update(user, body: {'role': 'customer'});
      debugPrint("Rollback role do lỗi: $e");
      return false;
    }
  }

  Future<DriverRequest?> fetchRequestByUserID(String userid) async {
    try {
      final request = await pb
          .collection('driverrequests')
          .getList(filter: 'user = "$userid"', expand: 'user');
      if (request.items.isEmpty) return null;
      return DriverRequest.fromRecord(request.items.first);
    } on ClientException catch (e) {
      logger.i(e.response);
      return null;
    }
  }

  Future<bool> retryDriverRequest(String id) async {
    try {
      final success = await pb
          .collection('driverrequests')
          .update(id, body: {'status': 'requested'});
      if (success.data.isEmpty) return false;
      return true;
    } on ClientException catch (e) {
      logger.i(e.response);
      return false;
    }
  }

  Future<bool> addMemberShip({
    required String user,
    required String plan,
    required int discountpercent,
  }) async {
    final startdate = DateTime.now();
    final enddate = startdate.add(const Duration(days: 90));
    // print(pb.authStore.isValid);
    // print(pb.authStore.model?.id);
    try {
      final body = {
        'user': user,
        'plan': plan,
        'startdate': startdate.toIso8601String(),
        'enddate': enddate.toIso8601String(),
        'discountpercent': discountpercent,
      };
      await pb.collection('memberships').create(body: body);
      return true;
    } catch (e) {
      debugPrint("Rollback role do lỗi: $e");
      return false;
    }
  }

  Future<Membership?> getCurrentMembership(String userId) async {
    try {
      final record = await pb
          .collection('memberships')
          .getFirstListItem('user = "$userId"');

      return Membership.fromRecord(record);
    } catch (e) {
      debugPrint('Không có membership: $e');
      return null;
    }
  }

  Future<User?> fetchUserById(String userId) async {
    try {
      final record = await pb.collection('users').getOne(userId);
      return User.fromJson(record.toJson());
    } catch (e) {
      debugPrint('Fetch user lỗi: $e');
      return null;
    }
  }
}
