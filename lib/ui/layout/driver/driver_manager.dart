import 'dart:async';

// import 'package:logger/logger.dart';
import 'package:booking_app/models/booking.dart';
import 'package:booking_app/models/driver.dart';
import 'package:booking_app/services/driver_service.dart';
import 'package:flutter/material.dart';

class DriverManager extends ChangeNotifier {
  // final logger = Logger();
  final DriverService _driverService = DriverService();

  List<BookingModel> _bookingRequests = [];
  List<BookingModel> get bookingRequests => _bookingRequests;

  List<Driver> _drivers = [];
  List<Driver> get drivers => _drivers;

  Driver? _driver;
  Driver? get driver => _driver;

  StreamSubscription<List<BookingModel>>? _bookingRequestsSub;
  StreamSubscription<List<Driver>>? _driversSub;
  StreamSubscription<Driver?>? _driverSub;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Booking Tracing nạ
  BookingModel? _currentBooking;
  BookingModel? get currentBooking => _currentBooking;

  StreamSubscription<BookingModel?>? _bookingTracingSub;
  // End

  String driverImageUrl(Driver d) {
    return _driverService.driverImageUrl(d);
  }

  // Future<void> fetchDriversOnline() async {
  //   _isLoading = true;
  //   notifyListeners();

  //   final result = await _driverService.fetchDriverOnline();
  //   _drivers = result ?? [];

  //   _isLoading = false;
  //   notifyListeners();
  // }

  void listenDriversOnline() {
    _driversSub?.cancel();
    _driversSub = _driverService.watchDriversOnline().listen((drivers) {
      _drivers = drivers;
      notifyListeners();
    });
  }

  void listenDriverOnline(driverId) {
    _driverSub?.cancel();
    _driverSub = _driverService.watchDriverOnline(driverId).listen((driver) {
      _driver = driver;
      notifyListeners();
    });
  }

  Future<bool> updateIsOnline(String driverId) async {
    return await _driverService.updateIsOnline(driverId);
  }

  Future<Driver?> fetchDriverById({required id}) async {
    _isLoading = true;
    return await _driverService.fetchDriverById(id);
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

  Future<Driver?> fetchDriverByUserId({required String userId}) async {
    // logger.i(userId);
    return await _driverService.getDriverByUserId(userId);
  }

  Future<String> getDriverIdByUserId(String userId) async {
    return await _driverService.getDriverIdByUserId(userId);
  }

  // void disposeBookingListener() {
  //   _bookingRequestsSub?.cancel();
  // }
  void disposeBookingListener() {
    _bookingRequestsSub?.cancel();
    _bookingRequestsSub = null;
    _bookingRequests = [];
    // notifyListeners();
  }

  // Booking Tracing nạ
  void listenBookingTracing(String driverId) {
    _bookingTracingSub?.cancel();

    _bookingTracingSub = _driverService.watchBookingTracing(driverId).listen((
      booking,
    ) {
      _currentBooking = booking;
      notifyListeners();
    });
  }

  Future<void> cancelAll() async {
    await _bookingRequestsSub?.cancel();
    await _driversSub?.cancel();
    await _driverSub?.cancel();
    await _bookingTracingSub?.cancel();
    _bookingRequests = [];
    _drivers = [];
    _driver = null;
    _currentBooking = null;
    // notifyListeners();
  }

  @override
  void dispose() {
    cancelAll();
    super.dispose();
  }

  Future<bool> checkOnTrip(String driverId) async {
    return await _driverService.checkOnTrip(driverId);
  }
}
