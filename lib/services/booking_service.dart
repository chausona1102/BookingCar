import 'dart:async';
import 'package:booking_app/models/booking.dart';
import 'package:booking_app/models/location.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:pocketbase/pocketbase.dart';
import 'pb_client.dart';
import 'package:logger/logger.dart';

class BookingService extends ChangeNotifier {
  final logger = Logger();
  PocketBase get pb => pocketBase;

  Future<bool> addBooking({
    required String userId,
    required double price,
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
    required String type,
    String status = 'pending',
  }) async {
    try {
      final pickupRecord = await pb
          .collection('locations')
          .create(body: pickupLocation.toJson());
      final dropoffRecord = await pb
          .collection('locations')
          .create(body: dropoffLocation.toJson());
      await pb
          .collection('bookings')
          .create(
            body: {
              'status': status,
              'price': price.toInt(),
              'user': userId,
              'pickuplocation': pickupRecord.id,
              'dropofflocation': dropoffRecord.id,
              'type': type,
              'bookingtime': DateTime.now().toIso8601String(),
            },
          );
      notifyListeners();
      return true;
    } catch (e) {
      logger.e('An error occured', error: e);
      return false;
    }
  }

  Future<BookingModel?> getCurrentTracing(String userId) async {
    try {
      final record = await pb
          .collection('bookings')
          .getFirstListItem(
            'user = "$userId" && status != "completed" && status != "cancelled"',
          );
      // logger.i(record.data);
      return BookingModel.fromRecord(record);
    } catch (e) {
      logger.i('Không tìm thấy Bookings');
      return null;
    }
  }

  Future<LocationModel?> getLocationById(String id) async {
    try {
      final record = await pb.collection('locations').getOne(id);
      // logger.i(record.data);
      return LocationModel.fromRecord(record);
    } catch (e, s) {
      logger.e('An error occured: ', error: e, stackTrace: s);
      return null;
    }
  }

  Future<BookingModel?> getCurrentBooking(String userId) async {
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            page: 1,
            perPage: 1,
            filter:
                'user = "$userId" && status != "completed" &&status != "cancelled"',
            sort: '-bookingtime',
          );

      if (records.items.isEmpty) {
        logger.w('Có bát quái ở BookingService.getCurrentBooking $userId');
        return null;
      }

      final booking = BookingModel.fromRecord(records.items.first);
      logger.i('Booking found: ${booking.id} - Status: ${booking.status}');

      return booking;
    } catch (e, s) {
      logger.e(
        'Lỗi ở hàm getCurrentBooking trong BookingService 🔥',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  Stream<BookingModel?> watchCurrentBooking(String userId) {
    final controller = StreamController<BookingModel?>.broadcast();

    Future<void> loadBooking() async {
      try {
        final booking = await getCurrentBooking(userId);
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
        .subscribe('*', (e) => loadBooking(), filter: "user = '$userId'");

    controller.onCancel = () async {
      await pb.collection('bookings').unsubscribe('*');
      await controller.close();
    };

    return controller.stream;
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await pb
          .collection('bookings')
          .update(bookingId, body: {'status': 'cancelled'});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkPending(String bookingId) async {
    try {
      await pb
          .collection('bookings')
          .getFirstListItem('id = "$bookingId" && status = "pending"');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<BookingModel>> fetchHistoryBookingOfUser(String userId) async {
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            filter:
                'user = "$userId" && (status = "completed" || status = "cancelled")',
            sort: '-bookingtime',
          );

      return records.items
          .map((record) => BookingModel.fromRecord(record))
          .toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<List<BookingModel>> fetchHistoryBookingOfDriver(String driver) async {
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            filter:
                'driver = "$driver" && (status = "completed" || status = "cancelled")',
            sort: '-bookingtime',
          );
      return records.items
          .map((record) => BookingModel.fromRecord(record))
          .toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<bool> addDriverId(String bookingId, String driverId) async {
    try {
      await pb
          .collection('bookings')
          .update(bookingId, body: {'driver': driverId, 'status': 'accepted'});
      return true;
    } catch (e) {
      return false;
    }
  }
}
