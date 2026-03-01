import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'user.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class Driver {
  final String id;
  final String licensenumber;
  final String typecar;
  final User user;
  final String carimage;
  final String carnumber;
  bool isonline;

  Driver({
    required this.id,
    required this.typecar,
    required this.licensenumber,
    required this.user,
    required this.carimage,
    required this.carnumber,
    this.isonline = false,
  });

  factory Driver.fromRecord(RecordModel r) {
    // ignore: unnecessary_cast
    final expanded = r.expand['user'] as List<RecordModel>?;

    if (expanded == null || expanded.isEmpty) {
      throw Exception('Driver ${r.id} không có user expand');
    }

    return Driver(
      id: r.id,
      typecar: r.getStringValue('typecar'),
      licensenumber: r.getStringValue('licensenumber'),
      user: User.fromJson(expanded.first.toJson()),
      carimage: r.getStringValue('carimage'),
      carnumber: r.getStringValue('carnumber'),
      isonline: r.data['isonline'] ?? false,
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

  String? get carImageURL {
    // ignore: unnecessary_null_comparison
    if (carimage == null || carimage.isEmpty) return null;

    final baseUrl = dotenv.env['POCKETBASE_URL'];
    final collection = dotenv.env['POCKETBASE_COLLECTION_DRIVER'] ?? 'drivers';

    if (baseUrl == null || baseUrl.isEmpty) return null;

    return '$baseUrl/api/files/$collection/$id/$carimage';
  }
}
