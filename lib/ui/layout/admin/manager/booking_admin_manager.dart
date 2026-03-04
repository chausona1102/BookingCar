import 'package:booking_app/models/booking.dart';
import 'package:booking_app/services/admin/booking_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class BookingAdminManager extends ChangeNotifier {
  final logger = Logger();
  final BookingAdminService _bookingAdminService = BookingAdminService();
  List<BookingModel> bookings = [];
  Future<void> fetchBookingLimit() async {
    bookings = (await _bookingAdminService.fetchLimitBooking())!;
    notifyListeners();
  }
}
