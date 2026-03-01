import 'dart:async';
import 'dart:io';

import 'package:booking_app/models/driver.dart';
import 'package:booking_app/services/admin/driver_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class DriverAdminManager extends ChangeNotifier {
  final logger = Logger();
  Timer? _debounce;
  final DriverAdminService driverAdminService = DriverAdminService();
  List<Driver> drivers = [];

  final DriverAdminService _driverAdminService = DriverAdminService();

  Future<void> fetchDriverLimit() async {
    drivers = (await driverAdminService.fetchDriverLimit())!;
    notifyListeners();
  }

  Future<bool> update({
    required String id,
    required String licenseNumber,
    required String carNumber,
    File? carImage,
  }) async {
    try {
      final success = await driverAdminService.update(
        id: id,
        licenseNumber: licenseNumber,
        carNumber: carNumber,
        carImage: carImage,
      );
      if (success) fetchDriverLimit();
      return success;
    } catch (e) {
      logger.i(e);
      return false;
    }
  }

  Future<bool> deleteDriverById(String id) async {
    return await _driverAdminService.delete(id);
  }

  Future<void> search(String key) async {
    print(key);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final result = await _driverAdminService.search(key);
      drivers = result ?? [];
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
