import 'package:booking_app/models/booking.dart';
import 'package:booking_app/services/pb_client.dart';
import 'package:logger/web.dart';
import 'package:pocketbase/pocketbase.dart';

class BookingAdminService {
  PocketBase get pb => pocketBase;
  final logger = Logger();

  Future<List<BookingModel>?> fetchLimitBooking() async {
    logger.i('Fetching Bookings...');
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            page: 1,
            perPage: 20,
            expand: 'user,driver,driver.user,pickuplocation,dropofflocation',
          );
      final result = <BookingModel>[];
      for (final r in records.items) {
        try {
          result.add(BookingModel.fromRecord(r));
        } catch (e) {
          logger.e('Lỗi parse booking ${r.id}: $e'); // booking nào bị lỗi
        }
      }
      return result;
    } on ClientException catch (e) {
      logger.e('PocketBase error: ${e.response}');
      return [];
    } catch (e, stack) {
      logger.e('Unexpected error: $e\n$stack');
      return [];
    }
  }
}
