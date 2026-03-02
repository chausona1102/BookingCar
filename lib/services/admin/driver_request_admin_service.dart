import 'package:booking_app/models/driverrequest.dart';
import 'package:booking_app/services/pb_client.dart';
import 'package:logger/web.dart';
import 'package:pocketbase/pocketbase.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class DriverRequestAdminService {
  PocketBase get pb => pocketBase;
  final logger = Logger();
  // String carImage(Driver d) {

  // }
  Future<List<DriverRequest>?> fetchRequestLimit() async {
    try {
      final records = await pb
          .collection('driverrequests')
          .getList(page: 1, perPage: 20, expand: 'user', sort: 'status');
      return records.items.map((r) => DriverRequest.fromRecord(r)).toList();
    } on ClientException catch (e) {
      final data = e.response;
      logger.i(data['message']);
      return [];
    }
  }

  Future<bool> updateStatusCancelled(String id) async {
    try {
      await pb
          .collection('driverrequests')
          .update(id, body: {'status': 'cancelled'});
      return true;
    } on ClientException catch (e) {
      final data = e.response;
      logger.i(data['message']);
      return false;
    }
  }

  Future<bool> updateStatusAccepted({
    required String id,
    required String status,
    required String user,
    required String licensenumber,
    required String typecar,
    required String carnumber,
    String? carimage,
  }) async {
    try {
      final success = await addDriver(
        licensenumber: licensenumber,
        typecar: typecar,
        user: user,
        carnumber: carnumber,
        carimageUrl: carimage,
      );
      if (!success) return false;
      await pb
          .collection('driverrequests')
          .update(id, body: {'status': status});
      return true;
    } on ClientException catch (e) {
      final data = e.response;
      logger.i(data['message']);
      return false;
    }
  }

  Future<bool> changeRole({required String user}) async {
    try {
      print('userid: $user');
      await pb.collection('users').update(user, body: {'role': 'driver'});
      return true;
    } catch (e) {
      logger.i('Lỗi changeRole: $e');
      return false;
    }
  }

  Future<bool> addDriver({
    required String licensenumber,
    required String typecar,
    required String user,
    required String carnumber,
    String? carimageUrl,
  }) async {
    try {
      final body = {
        'licensenumber': licensenumber,
        'typecar': typecar,
        'user': user,
        'carnumber': carnumber,
        'isonline': true,
      };
      final roleChange = await changeRole(user: user);
      if (!roleChange) return false;
      final files = <http.MultipartFile>[];

      if (carimageUrl != null && carimageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(carimageUrl));
        if (response.statusCode == 200) {
          files.add(
            http.MultipartFile.fromBytes(
              'carimage',
              response.bodyBytes,
              filename: 'carimage.jpg',
            ),
          );
        }
      }
      await pb.collection('drivers').create(body: body, files: files);
      return true;
    } catch (e) {
      await pb.collection('users').update(user, body: {'role': 'customer'});
      logger.i("Rollback role do lỗi: $e");
      return false;
    }
  }

  Future<List<DriverRequest>?> search(String key) async {
    try {
      final records = await pb
          .collection('driverrequests')
          .getList(
            expand: 'user',
            filter:
                'id ~ "$key" || user.username ~ "$key" || user.firstname ~ "$key" || user.lastname ~ "$key" || status ~ "$key" || typecar ~ "$key" || carnumber ~ "$key" || user.email ~ "$key" || user.phone ~ "$key"',
          );
      return records.items.map((r) => DriverRequest.fromRecord(r)).toList();
    } catch (e) {
      return [];
    }
  }
}
