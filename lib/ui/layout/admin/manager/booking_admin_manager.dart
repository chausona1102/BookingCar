import 'dart:async';

import 'package:booking_app/models/booking.dart';
import 'package:booking_app/services/admin/booking_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class BookingAdminManager extends ChangeNotifier {
  final logger = Logger();
  final BookingAdminService _bookingAdminService = BookingAdminService();
  List<BookingModel> _allBookings = [];
  List<BookingModel> bookings = [];
  List<BookingModel> bookingMore = [];

  Timer? _debounce;
  Future<void> fetchBookingLimit() async {
    _allBookings = (await _bookingAdminService.fetchLimitBooking())!;
    bookings = _allBookings;
    notifyListeners();
  }

  Future<void> fetchMoreLimit() async {
    bookingMore = (await _bookingAdminService.fetchMoreBooking())!;
    if (bookingMore.isNotEmpty) {
      bookings.addAll(bookingMore);
    }
    notifyListeners();
  }

  void filterByStatus(String status) {
    if (status == 'All') {
      bookings = _allBookings;
    } else {
      bookings = _allBookings.where((b) => b.status == status).toList();
    }
    notifyListeners();
  }

  void sortBookingByPrice(String type) {
    switch (type) {
      case 'asc':
        ascBookingByPrice();
        break;
      case 'desc':
        descBookingByPrice();
        break;
      default:
        ascBookingByPrice();
    }
  }

  void ascBookingByPrice() {
    bookings.sort((a, b) => a.price.compareTo(b.price));
    notifyListeners();
  }

  void descBookingByPrice() {
    bookings.sort((a, b) => b.price.compareTo(a.price));
    notifyListeners();
  }

  void sortBookingByDate(String type) {
    switch (type) {
      case 'asc':
        ascBookingByDate();
        break;
      case 'desc':
        descBookingByDate();
        break;
      default:
        ascBookingByDate();
    }
  }

  void ascBookingByDate() {
    bookings.sort((a, b) => a.bookingTime.compareTo(b.bookingTime));
    notifyListeners();
  }

  void descBookingByDate() {
    bookings.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));
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
