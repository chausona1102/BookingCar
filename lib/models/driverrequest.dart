import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'user.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

final logger = Logger();

class DriverRequest {
  final String id;
  final String licensenumber;
  final String status;
  final String typecar;
  final User user;
  final String carimage;
  final String carnumber;
  final DateTime? createat;
  final DateTime? updated;

  DriverRequest({
    required this.id,
    required this.typecar,
    required this.licensenumber,
    required this.status,
    required this.user,
    required this.carimage,
    required this.carnumber,
    this.createat,
    this.updated,
  });

  factory DriverRequest.fromRecord(RecordModel r) {
    final expanded = (r.expand['user'] as List?)?.cast<RecordModel>();

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
      createat: DateTime.tryParse(r.getStringValue('createat')),
      updated: DateTime.tryParse(r.updated),
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

  String get createTimeFormatted {
    return DateFormat('dd/MM/yyyy HH:mm').format(createat!);
  }

  String get createDate {
    return DateFormat('dd/MM/yyyy').format(createat!);
  }

  String get createHour {
    return DateFormat('HH:mm').format(createat!);
  }

  String get updateTimeFormatted {
    return DateFormat('dd/MM/yyyy HH:mm').format(updated!);
  }

  String get updateDate {
    return DateFormat('dd/MM/yyyy').format(updated!);
  }

  String get updateHour {
    return DateFormat('HH:mm').format(updated!);
  }

  String? get carImageURL {
    if (carimage.isEmpty) return null;

    final baseUrl = dotenv.env['POCKETBASE_URL'];
    final collection =
        dotenv.env['POCKETBASE_COLLECTION_DRIVER_REQUESTS'] ?? 'driverrequests';

    if (baseUrl == null || baseUrl.isEmpty) return null;

    return '$baseUrl/api/files/$collection/$id/$carimage';
  }
}
