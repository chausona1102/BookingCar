import 'package:booking_app/models/booking.dart';
import 'package:booking_app/services/pb_client.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class StatisticalService {
  PocketBase get pb => pocketBase;
  final logger = Logger();

  Future<List<BookingModel>?> fetchAllBookings() async {
    try {
      final records = await pb
          .collection('bookings')
          .getFullList(
            expand: 'user,driver,driver.user,pickuplocation,dropofflocation',
          );
      return records.map((r) => BookingModel.fromRecord(r)).toList();
    } on ClientException catch (e) {
      logger.i(e.response);
      return [];
    }
  }
}
