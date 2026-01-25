import 'package:pocketbase/pocketbase.dart';

class Membership {
  final String plan;
  final int discountPercent;
  final DateTime endDate;

  Membership({
    required this.plan,
    required this.discountPercent,
    required this.endDate,
  });

  factory Membership.fromRecord(RecordModel r) {
    return Membership(
      plan: r.data['plan'] ?? '',
      discountPercent: r.data['discountpercent'] ?? 0,
      endDate: DateTime.tryParse(r.data['enddate'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isExpired => endDate.isBefore(DateTime.now());
}
