import 'dart:ffi';

import 'package:go_router/go_router.dart';
import 'package:booking_app/models/booking.dart';
import 'package:booking_app/models/location.dart';
import 'package:booking_app/services/booking_service.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class BookingManager extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final logger = Logger();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  Future<bool> addBooking({
    required String userId,
    required double price,
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
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
      // context.push('/tracing');
    } else {
      return false;
    }
  }

  Future<LocationModel?> getLocationById({required id}) async {
    return await _bookingService.getLocationById(id);
  }
}
