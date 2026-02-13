import 'dart:async';

import 'package:booking_app/models/booking.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/driver.dart';
import 'pb_client.dart';

class DriverService {
  PocketBase get pb => pocketBase;
  final logger = Logger();
  String driverImageUrl(Driver d) {
    return '${pocketBase.baseUrl}/api/files/drivers/${d.id}/${d.carimage}';
  }

  Future<List<Driver>> fetchDriverLimit() async {
    final res = await pb
        .collection('drivers')
        .getList(page: 1, perPage: 20, expand: 'user');

    return res.items.map((e) => Driver.fromRecord(e)).toList();
  }

  Future<Driver?> fetchDriverByUserId(String driverId) async {
    try {
      final record = await pb
          .collection('drivers')
          .getFirstListItem('id="$driverId"', expand: 'user');
      return Driver.fromRecord(record);
    } catch (e) {
      logger.e('Không tìm thấy driver của user $driverId', error: e);
      return null;
    }
  }

  Future<List<BookingModel>?> fetchBookingRequest(driverId) async {
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            filter: "driver = null && status = 'pending'",
            sort: '-bookingtime',
          );
      return records.items.map((e) => BookingModel.fromRecord(e)).toList();
    } catch (e) {
      logger.i('Không tìm thấy Bookings');
      return null;
    }
  }

  Stream<List<BookingModel>> watchBookingRequest(driverId) {
    final controller = StreamController<List<BookingModel>>.broadcast();
    // print(driverId);
    Future<void> loadBookings() async {
      try {
        final bookings = await fetchBookingRequest(driverId);
        if (!controller.isClosed && bookings != null) {
          controller.add(bookings);
        }
      } catch (e) {
        logger.e('Error fetching booking after realtime event', error: e);
      }
    }

    loadBookings();

    pb
        .collection('bookings')
        .subscribe(
          '*',
          (e) => loadBookings(),
          filter:
              "driver = null || status = 'pending' || (driver != null && status = 'accepted')",
        );

    controller.onCancel = () async {
      await pb.collection('bookings').unsubscribe('*');
      await controller.close();
    };

    return controller.stream;
  }

  Future<String> getDriverIdByUserId(String userId) async {
    try {
      final record = await pb
          .collection('drivers')
          .getFirstListItem('user = "$userId"');
      return record.id;
    } catch (e) {
      return '';
    }
  }
}
