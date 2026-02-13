import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';

class BookingModel {
  final String? id;
  final String status;
  final double price;
  final String userId;
  final String? driverId;
  final String pickupLocationId;
  final String dropoffLocationId;
  final String type;
  final DateTime bookingTime;

  BookingModel({
    this.id,
    required this.status,
    required this.price,
    required this.userId,
    this.driverId,
    required this.pickupLocationId,
    required this.dropoffLocationId,
    required this.type,
    required this.bookingTime,
  });

  String get bookingTimeFormatted {
    return DateFormat('dd/MM/yyyy HH:mm').format(bookingTime.toLocal());
  }

  String get bookingDate {
    return DateFormat('dd/MM/yyyy').format(bookingTime.toLocal());
  }

  String get bookingHour {
    return DateFormat('HH:mm').format(bookingTime.toLocal());
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'price': price,
      'user': userId,
      'driver': driverId,
      'pickuplocation': pickupLocationId,
      'dropofflocation': dropoffLocationId,
      'type': type,
      'bookingtime': bookingTime.toIso8601String(),
    };
  }

  factory BookingModel.fromRecord(RecordModel r) {
    return BookingModel(
      id: r.id,
      status: r.data['status'].toString(),
      price: (r.data['price'] as num).toDouble(),
      userId: r.data['user'].toString(),
      driverId: r.data['driver']?.toString(),
      pickupLocationId: r.data['pickuplocation'].toString(),
      dropoffLocationId: r.data['dropofflocation'].toString(),
      type: r.data['type'].toString(),
      bookingTime: DateTime.parse(r.data['bookingtime']),
    );
  }
}
