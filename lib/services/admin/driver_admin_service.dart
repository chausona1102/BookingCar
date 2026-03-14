import 'dart:io';

import 'package:booking_app/models/driver.dart';
import 'package:booking_app/services/pb_client.dart';
import 'package:logger/web.dart';
import 'package:pocketbase/pocketbase.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class DriverAdminService {
  PocketBase get pb => pocketBase;
  final logger = Logger();
  var page = 1;
  String driverImageUrl(Driver d) {
    return '${pocketBase.baseUrl}/api/files/drivers/${d.id}/${d.carimage}';
  }

  Future<List<Driver>?> fetchDriverLimit() async {
    logger.i('Fetching Drivers....');
    page = 1;
    try {
      final records = await pb
          .collection('drivers')
          .getList(page: page, perPage: 20, expand: 'user');
      return records.items.map((r) => Driver.fromRecord(r)).toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<List<Driver>?> fetchMoreDriver() async {
    logger.i('Fetching Drivers....');
    page++;
    try {
      final records = await pb
          .collection('drivers')
          .getList(page: page, perPage: 20, expand: 'user');
      return records.items.map((r) => Driver.fromRecord(r)).toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<bool> update({
    required String id,
    required String licenseNumber,
    required String carNumber,
    File? carImage,
  }) async {
    try {
      final body = {'licensenumber': licenseNumber, 'carnumber': carNumber};
      if (carImage != null) {
        await pb
            .collection('drivers')
            .update(
              id,
              body: body,
              files: [
                await http.MultipartFile.fromPath('carimage', carImage.path),
              ],
            );
      } else {
        await pb.collection('drivers').update(id, body: body);
      }

      return true;
    } catch (e) {
      logger.i(e);
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await pb.collection('drivers').delete(id);
      return true;
    } on ClientException catch (e) {
      logger.i(e);
      return false;
    }
  }

  Future<List<Driver>?> search(String key) async {
    logger.i('Searching: $key');
    try {
      final result = await pb
          .collection('drivers')
          .getList(
            expand: 'user',
            filter:
                'id ~ "$key" || licensenumber ~ "$key" || carnumber ~ "$key" || user.username ~ "$key" || user.phone ~ "$key" || user.email ~ "$key" || user.firstname ~ "$key" || user.lastname ~ "$key"',
          );
      return result.items.map((r) => Driver.fromRecord(r)).toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }
}
