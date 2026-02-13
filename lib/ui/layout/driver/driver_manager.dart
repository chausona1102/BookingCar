import 'dart:async';

import 'package:booking_app/models/booking.dart';
import 'package:booking_app/models/driver.dart';
import 'package:booking_app/services/driver_service.dart';
import 'package:flutter/material.dart';

class DriverManager extends ChangeNotifier {
  final DriverService _driverService = DriverService();
  List<BookingModel> _bookingRequests = [];
  List<BookingModel> get bookingRequests => _bookingRequests;
  StreamSubscription<List<BookingModel>>? _bookingRequestsSub;
  List<Driver> drivers = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchDrivers() async {
    print('Fetching...');
    _isLoading = true;
    notifyListeners();
    drivers = await _driverService.fetchDriverLimit();
    _isLoading = false;
    notifyListeners();
  }

  String driverImageUrl(Driver d) {
    return _driverService.driverImageUrl(d);
  }

  Future<Driver?> fetchDriverById({required id}) async {
    _isLoading = true;
    return await _driverService.fetchDriverByUserId(id);
  }

  void listenBookingRequests(driverId) {
    _bookingRequestsSub?.cancel();
    _bookingRequestsSub = _driverService.watchBookingRequest(driverId).listen((
      bookings,
    ) {
      _bookingRequests = bookings;
      notifyListeners();
    });
  }

  void disposeBookingListener() {
    _bookingRequestsSub?.cancel();
  }

  @override
  void dispose() {
    _bookingRequestsSub?.cancel();
    super.dispose();
  }

  Future<String> getDriverIdByUserId(String userId) async {
    return await _driverService.getDriverIdByUserId(userId);
  }
}
