import 'dart:async';

import 'package:booking_app/models/booking.dart';
import 'package:booking_app/services/admin/booking_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class BookingAdminManager extends ChangeNotifier {
  final logger = Logger();
  final BookingAdminService _bookingAdminService = BookingAdminService();
  List<BookingModel> bookings = [];

  Timer? _debounce;
  Future<void> fetchBookingLimit() async {
    bookings = (await _bookingAdminService.fetchLimitBooking())!;
    notifyListeners();
  }

  Future<void> search(String key) async {
    print(key);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final result = await _bookingAdminService.search(key);
      bookings = result ?? [];
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _debounce?.cancel();
    super.dispose();
  }
}
