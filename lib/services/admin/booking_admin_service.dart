import 'package:booking_app/models/booking.dart';
import 'package:booking_app/services/pb_client.dart';
import 'package:logger/web.dart';
import 'package:pocketbase/pocketbase.dart';

class BookingAdminService {
  PocketBase get pb => pocketBase;
  final logger = Logger();
  var page = 1;
  Future<List<BookingModel>?> fetchLimitBooking() async {
    logger.i('Fetching Bookings...');
    page = 1; 
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            page: page,
            perPage: 20,
            expand: 'user,driver,driver.user,pickuplocation,dropofflocation',
          );
      final result = <BookingModel>[];
      for (final r in records.items) {
        try {
          result.add(BookingModel.fromRecord(r));
        } catch (e) {
          logger.e('Lỗi parse booking ${r.id}: $e');
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

  Future<List<BookingModel>?> fetchMoreBooking() async {
    page++;
    try {
      final records = await pb
          .collection('bookings')
          .getList(
            page: page,
            perPage: 20,
            expand: 'user,driver,driver.user,pickuplocation,dropofflocation',
          );
      final result = <BookingModel>[];
      for (final r in records.items) {
        try {
          result.add(BookingModel.fromRecord(r));
        } catch (e) {
          logger.e('Lỗi parse booking ${r.id}: $e');
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

  Future<List<BookingModel>?> search(String key) async {
    logger.i('Searching: $key');
    try {
      final result = await pb
          .collection('bookings')
          .getList(
            expand: 'user,driver,driver.user,pickuplocation,dropofflocation',
            filter:
                'id ~ "$key" || driver.id ~ "$key" || user.id ~ "$key" || pickuplocation.placename ~ "$key" || user.lastname ~ "$key" || user.firstname ~ "$key" || user.email ~ "$key"',
          );
      return result.items.map((r) => BookingModel.fromRecord(r)).toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }
}
