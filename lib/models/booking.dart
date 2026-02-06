import 'package:pocketbase/pocketbase.dart';

class BookingModel {
  final String? id;
  final String status;
  final double price;
  final String userId;
  final String? driverId;
  final String pickupLocationId;
  final String dropoffLocationId;
  final DateTime bookingTime;
  BookingModel({
    this.id,
    required this.status,
    required this.price,
    required this.userId,
    this.driverId,
    required this.pickupLocationId,
    required this.dropoffLocationId,
    required this.bookingTime,
  });
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'price': price,
      'user': userId,
      'driver': driverId,
      'pickuplocation': pickupLocationId,
      'dropofflocation': dropoffLocationId,
      'bookingtime': bookingTime.toIso8601String(),
    };
  }

  factory BookingModel.fromRecord(RecordModel r) {
    return BookingModel(
      status: (r.data['status']).toString(),
      price: (r.data['price'] as num).toDouble(),
      userId: (r.data['user']).toString(),
      pickupLocationId: (r.data['pickuplocation']).toString(),
      dropoffLocationId: (r.data['dropofflocation']).toString(),
      bookingTime: DateTime.parse(r.data['bookingtime']),
    );
  }
}
