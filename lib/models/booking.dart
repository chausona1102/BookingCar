import 'package:booking_app/models/location.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/models/driver.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';

class BookingModel {
  final String? id;
  final String status;
  final double price;
  final User user;
  final Driver?
  driver; // nullable — booking may not have an assigned driver yet
  final LocationModel pickupLocation;
  final LocationModel dropoffLocation;
  final String type;
  final DateTime bookingTime;

  BookingModel({
    this.id,
    required this.status,
    required this.price,
    required this.user,
    this.driver,
    required this.pickupLocation,
    required this.dropoffLocation,
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
      'user': user.toJson(),
      'driver': driver?.toJson(),
      'pickuplocation': pickupLocation,
      'dropofflocation': dropoffLocation,
      'type': type,
      'bookingtime': bookingTime.toIso8601String(),
    };
  }

  factory BookingModel.fromRecord(RecordModel r) {
    // ignore: unnecessary_cast, deprecated_member_use
    final expandedUser = r.expand['user'] as List<RecordModel>?;
    // ignore: unnecessary_cast, deprecated_member_use
    final expandedDriver = r.expand['driver'] as List<RecordModel>?;

    final expandedPickUpLocation =
        r.expand['pickuplocation'] as List<RecordModel>?;
    final expandedDropOffLocation =
        r.expand['dropofflocation'] as List<RecordModel>?;

    if (expandedUser == null || expandedUser.isEmpty) {
      throw Exception('Booking ${r.id} has no user expand');
    }

    if (expandedPickUpLocation == null || expandedPickUpLocation.isEmpty) {
      throw Exception('Booking ${r.id} has no pickup expand');
    }

    if (expandedDropOffLocation == null || expandedDropOffLocation.isEmpty) {
      throw Exception('Booking ${r.id} has no dropoff expand');
    }

    final driver = (expandedDriver != null && expandedDriver.isNotEmpty)
        ? Driver.fromJson(expandedDriver.first.toJson())
        : null;

    return BookingModel(
      id: r.id,
      status: r.data['status'].toString(),
      price: (r.data['price'] as num).toDouble(),
      user: User.fromJson(expandedUser.first.toJson()),
      driver: driver,
      pickupLocation: LocationModel.fromJson(
        expandedPickUpLocation.first.toJson(),
      ),
      dropoffLocation: LocationModel.fromJson(
        expandedDropOffLocation.first.toJson(),
      ),
      type: r.data['type'].toString(),
      bookingTime: DateTime.parse(r.data['bookingtime']),
    );
  }
}
