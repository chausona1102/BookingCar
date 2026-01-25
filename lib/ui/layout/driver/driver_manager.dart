import 'package:booking_app/models/driver.dart';
import 'package:booking_app/services/driver_service.dart';
import 'package:flutter/material.dart';

class DriverManager extends ChangeNotifier {
  final DriverService _driverService = DriverService();
  List<Driver> drivers = [];
  bool _isLoading = false;
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
}
