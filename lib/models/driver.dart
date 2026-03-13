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
      throw Exception('Driver ${r.id} has no user expand');
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

  factory Driver.fromJson(Map<String, dynamic> json) {
    final userJson = json['expand']?['user'];

    final resolvedUserJson = userJson is List
        ? (userJson.isNotEmpty ? userJson.first as Map<String, dynamic> : null)
        : userJson as Map<String, dynamic>?;

    if (resolvedUserJson == null) {
      throw Exception('Driver ${json['id']} has no user expand');
    }

    return Driver(
      id: json['id'].toString(),
      typecar: json['typecar']?.toString() ?? '',
      licensenumber: json['licensenumber']?.toString() ?? '',
      user: User.fromJson(resolvedUserJson),
      carimage: json['carimage']?.toString() ?? '',
      carnumber: json['carnumber']?.toString() ?? '',
      isonline: json['isonline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typecar': typecar,
      'licensenumber': licensenumber,
      'user': user.toJson(),
      'carimage': carimage,
      'carnumber': carnumber,
      'isonline': isonline,
    };
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
    if (carimage.isEmpty) return null;

    final baseUrl = dotenv.env['POCKETBASE_URL'];
    final collection = dotenv.env['POCKETBASE_COLLECTION_DRIVER'] ?? 'drivers';

    if (baseUrl == null || baseUrl.isEmpty) return null;

    return '$baseUrl/api/files/$collection/$id/$carimage';
  }
}
