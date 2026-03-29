import 'dart:async';

import 'package:booking_app/models/booking.dart';
import 'package:booking_app/models/location.dart';
import 'package:booking_app/services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

class BookingManager extends ChangeNotifier {
  BookingModel? _currentBooking;
  BookingModel? get currentBooking => _currentBooking;
  final BookingService _bookingService = BookingService();
  StreamSubscription<BookingModel?>? _bookingSub;
  final Map<String, LocationModel> _locations = {};
  Map<String, LocationModel> get locations => _locations;

  final logger = Logger();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String> getPlaceName(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) {
        return '(${latLng.latitude.toStringAsFixed(4)}, '
            '${latLng.longitude.toStringAsFixed(4)})';
      }

      final p = placemarks.first;

      final parts = [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((e) => e != null && e.isNotEmpty).toList();

      if (parts.isEmpty) {
        return '(${latLng.latitude.toStringAsFixed(4)}, '
            '${latLng.longitude.toStringAsFixed(4)})';
      }

      return parts.join(', ');
    } catch (e) {
      return '(${latLng.latitude.toStringAsFixed(4)}, '
          '${latLng.longitude.toStringAsFixed(4)})';
    }
  }

  double calculatePayment(double? distance, String? type) {
    double? total = 0;
    if (distance == null) return 0;
    switch (type) {
      case 'car':
        total += 30000;
        total += (distance - 1) * 16000;
        break;
      case 'motobike':
        total += 20000;
        total += (distance - 1) * 12000;
        break;
      case 'driver':
        total += 15000;
        total += (distance - 1) * 10000;
        break;
    }

    return total;
  }

  double calculatePaymentWithDisCount(
    double? distance,
    String? type,
    double disCount,
  ) {
    double? total = 0;
    if (distance == null) return 0;
    switch (type) {
      case 'car':
        total += 30000;
        total += (distance - 1) * 16000;
        break;
      case 'motobike':
        total += 20000;
        total += (distance - 1) * 12000;
        break;
      case 'driver':
        total += 30000;
        total += (distance - 1) * 16000;
        break;
    }
    logger.i(disCount);
    print(total);
    return total * (1 - disCount);
  }

  Future<bool> addBooking({
    required String userId,
    required double price,
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
    required String type,
    String status = 'pending',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _bookingService.addBooking(
        userId: userId,
        price: price,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        type: type,
        status: status,
      );
    } catch (e) {
      logger.e('An error occured: ', error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBookingWithDriver({
    required String userId,
    required double price,
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
    required String driverId,
    required String type,
    String status = 'pending',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _bookingService.addBookingWithDriver(
        userId: userId,
        price: price,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        type: type,
        driverId: driverId,
        status: status,
      );
    } catch (e) {
      logger.e('An error occured: ', error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BookingModel?> getCurrentTracing({required userId}) async {
    return await _bookingService.getCurrentTracing(userId);
  }

  Future<bool> checkTracing(BuildContext context, {required userId}) async {
    final tracing = await getCurrentTracing(userId: userId);
    if (tracing != null) {
      // snackBarLogger(context, 'Bạn đang trong cuốc xe!', 'error');
      return true;
    } else {
      return false;
    }
  }

  // Real time tracing
  Future<LocationModel?> getLocationById({required id}) async {
    return await _bookingService.getLocationById(id);
  }

  void listenCurrentBooking(String userId) {
    _bookingSub?.cancel();

    _bookingSub = _bookingService
        .watchCurrentBooking(userId)
        .listen(
          (booking) {
            _currentBooking = booking;
            notifyListeners();
          },
          onError: (error) {
            logger.e(
              'Có lỗi ở Booking Manager - listenCurrentBooking(): ',
              error: error,
            );
          },
        );
  }

  Future<void> fetchLocation(String id) async {
    if (_locations.containsKey(id)) return;

    final location = await getLocationById(id: id);

    if (location != null) {
      _locations[id] = location;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _bookingService.updateBookingStatus(bookingId, status);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<BookingModel>> fetchHistoryBookingOfUser(String userId) async {
    return await _bookingService.fetchHistoryBookingOfUser(userId);
  }

  Future<List<BookingModel>> fetchHistoryBookingOfDriver(String driver) async {
    return await _bookingService.fetchHistoryBookingOfDriver(driver);
  }

  Future<bool> checkPending(String bookingId) async {
    try {
      await _bookingService.checkPending(bookingId);
      return true;
    } catch (e) {
      logger.e('An errro in BookingManager', error: e);
      return false;
    }
  }

  Future<bool> addDriverId(String bookingId, String driverId) async {
    try {
      await _bookingService.addDriverId(bookingId, driverId);
      return true;
    } catch (e) {
      logger.e('An errro in BookingManager', error: e);
      return false;
    }
  }
}
