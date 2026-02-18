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

  Future<bool> updateIsOnline(String driverId) async {
    try {
      final record = await pb.collection('drivers').getOne(driverId);

      final currentStatus = record.data['isonline'] ?? false;

      await pb
          .collection('drivers')
          .update(driverId, body: {'isonline': !currentStatus});

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Driver>> fetchDriverLimit() async {
    final res = await pb
        .collection('drivers')
        .getList(page: 1, perPage: 20, expand: 'user');

    return res.items.map((e) => Driver.fromRecord(e)).toList();
  }

  Future<List<Driver>?> fetchDriverOnline() async {
    final res = await pb
        .collection('drivers')
        .getList(
          page: 1,
          perPage: 20,
          expand: 'user',
          filter: 'isonline = true',
        );

    return res.items.map((e) => Driver.fromRecord(e)).toList();
  }

  Stream<List<Driver>> watchDriversOnline() {
    final controller = StreamController<List<Driver>>.broadcast();

    Future<void> loadDrivers() async {
      try {
        final drivers = await fetchDriverOnline();
        if (!controller.isClosed && drivers != null) {
          controller.add(drivers);
        }
      } catch (e) {
        logger.e('Error fetching driver after realtime event', error: e);
      }
    }

    loadDrivers();
    pb
        .collection('drivers')
        .subscribe(
          '*',
          (e) => loadDrivers(),
          filter: 'isonline = true || isonline = false',
        );
    controller.onCancel = () async {
      await pb.collection('drivers').unsubscribe('*');
      await controller.close();
    };
    return controller.stream;
  }

  Stream<Driver?> watchDriverOnline(String driverId) {
    final controller = StreamController<Driver?>.broadcast();

    Future<void> loadDriver() async {
      try {
        final driver = await fetchDriverById(driverId);
        if (!controller.isClosed) {
          controller.add(driver);
        }
      } catch (e) {
        logger.e('Error fetching driver', error: e);
      }
    }

    loadDriver();

    pb.collection('drivers').subscribe(driverId, (e) => loadDriver());

    controller.onCancel = () async {
      await pb.collection('drivers').unsubscribe(driverId);
      await controller.close();
    };

    return controller.stream;
  }

  Future<Driver?> fetchDriverById(String driverId) async {
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

  Future<Driver?> getDriverByUserId(String userId) async {
    try {
      final record = await pb
          .collection('drivers')
          .getFirstListItem('user="$userId"', expand: 'user');
      return Driver.fromRecord(record);
    } catch (e) {
      return null;
    }
  }

  Future<BookingModel?> fetchBookingTracing(driverId) async {
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            filter:
                "driver = '$driverId' && status != 'pending' && status != 'completed' && status != 'cancelled'",
            sort: '-bookingtime',
            perPage: 1,
          );
      if (records.items.isEmpty) return null;
      return BookingModel.fromRecord(records.items.first);
    } catch (e) {
      logger.i('Không tìm thấy Bookings');
      return null;
    }
  }

  Stream<BookingModel?> watchBookingTracing(String driverId) {
    final controller = StreamController<BookingModel?>.broadcast();

    Future<void> loadBooking() async {
      try {
        final booking = await fetchBookingTracing(driverId);
        if (!controller.isClosed) {
          controller.add(booking);
        }
      } catch (error) {
        logger.e('Error fetching booking', error: error);
      }
    }

    loadBooking();

    pb
        .collection('bookings')
        .subscribe(
          '*',
          (e) => loadBooking(),
          filter:
              "driver = '$driverId' && status != 'pending' && status != 'completed' && status != 'cancelled'",
        );

    controller.onCancel = () async {
      await pb.collection('bookings').unsubscribe('*');
      await controller.close();
    };

    return controller.stream;
  }

  Future<bool> checkOnTrip(String driverId) async {
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            page: 1,
            perPage: 1,
            filter:
                "driver = '$driverId' && status != 'completed' && status != 'cancelled'",
          );

      return records.items.isNotEmpty;
    } catch (e) {
      logger.e('Error checkOnTrip', error: e);
      return false;
    }
  }
}
