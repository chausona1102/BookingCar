import 'package:booking_app/models/membership.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'pb_client.dart';

class CustomerService extends ChangeNotifier {
  PocketBase get pb => pocketBase;
  Future<bool> changeRole({required String user}) async {
    try {
      print('userid: $user');
      await pb.collection('users').update(user, body: {'role': 'driver'});
      return true;
    } catch (e) {
      debugPrint('Lỗi changeRole: $e');
      return false;
    }
  }

  Future<bool> addDriver({
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
      };
      final roleChange = await changeRole(user: user);
      if (!roleChange) return false;
      final files = <http.MultipartFile>[];
      if (carimage != null) {
        files.add(await http.MultipartFile.fromPath('carimage', carimage.path));
      }
      await pb.collection('drivers').create(body: body, files: files);
      return true;
    } catch (e) {
      await pb.collection('users').update(user, body: {'role': 'customer'});
      debugPrint("Rollback role do lỗi: $e");
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
}
