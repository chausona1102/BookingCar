import 'package:pocketbase/pocketbase.dart';
import 'user.dart';

class Driver {
  final String id;
  final String licensenumber;
  final String typecar;
  final User user;
  final String carimage;
  final String carnumber;

  Driver({
    required this.id,
    required this.typecar,
    required this.licensenumber,
    required this.user,
    required this.carimage,
    required this.carnumber,
  });

  factory Driver.fromRecord(RecordModel r) {
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
    );
  }
}
