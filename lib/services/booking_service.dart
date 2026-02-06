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
          .getFirstListItem('user = "$userId"');
      logger.i(record.data);
      return BookingModel.fromRecord(record);
    } catch (e) {
      logger.e('An error occured: ', error: e);
    }
  }
}
