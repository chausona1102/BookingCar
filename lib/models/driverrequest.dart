import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'user.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class DriverRequest {
  final String id;
  final String licensenumber;
  final String status;
  final String typecar;
  final User user;
  final String carimage;
  final String carnumber;

  DriverRequest({
    required this.id,
    required this.typecar,
    required this.licensenumber,
    required this.status,
    required this.user,
    required this.carimage,
    required this.carnumber,
  });

  factory DriverRequest.fromRecord(RecordModel r) {
    // ignore: unnecessary_cast
    final expanded = r.expand['user'] as List<RecordModel>?;

    if (expanded == null || expanded.isEmpty) {
      throw Exception('DriverRequest ${r.id} không có user expand');
    }

    return DriverRequest(
      id: r.id,
      typecar: r.getStringValue('typecar'),
      status: r.getStringValue('status'),
      licensenumber: r.getStringValue('licensenumber'),
      user: User.fromJson(expanded.first.toJson()),
      carimage: r.getStringValue('carimage'),
      carnumber: r.getStringValue('carnumber'),
    );
  }

  String get typeCar {
    switch (typecar) {
      case 'car':
        return 'Ô tô';
      case 'motobike':
        return 'Xe máy';
      default:
        return 'Ô tô';
    }
  }

  String get getStatus {
    switch (status) {
      case 'requested':
        return 'Chờ duyệt';
      case 'accepted':
        return 'Đã duyệt';
      case 'cancelled':
        return 'Từ chối';
      default:
        return 'Chờ duyệt';
    }
  }

  String? get carImageURL {
    // ignore: unnecessary_null_comparison
    if (carimage == null || carimage.isEmpty) return null;

    final baseUrl = dotenv.env['POCKETBASE_URL'];
    final collection =
        dotenv.env['POCKETBASE_COLLECTION_DRIVER_REQUESTS'] ?? 'driverrequests';

    if (baseUrl == null || baseUrl.isEmpty) return null;

    return '$baseUrl/api/files/$collection/$id/$carimage';
  }
}
