import 'package:pocketbase/pocketbase.dart';
import '../models/driver.dart';
import 'pb_client.dart';

class DriverService {
  PocketBase get pb => pocketBase;

  String driverImageUrl(Driver d) {
    return '${pocketBase.baseUrl}/api/files/drivers/${d.id}/${d.carimage}';
  }

  // Future<List<User>> fetchDriverLimit() async {
  //   print('Service Fetching...');
  //   return [];
  // }
  Future<List<Driver>> fetchDriverLimit() async {
    final res = await pb
        .collection('drivers')
        .getList(page: 1, perPage: 20, expand: 'user');

    return res.items.map((e) => Driver.fromRecord(e)).toList();
  }
}
