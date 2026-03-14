import 'dart:async';
import 'dart:io';

import 'package:booking_app/models/driver.dart';
import 'package:booking_app/services/admin/driver_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class DriverAdminManager extends ChangeNotifier {
  final logger = Logger();
  Timer? _debounce;
  List<Driver> drivers = [];
  List<Driver> _allDriver = [];

  final DriverAdminService _driverAdminService = DriverAdminService();

  Future<void> fetchDriverLimit() async {
    _allDriver = (await _driverAdminService.fetchDriverLimit())!;
    drivers = _allDriver;
    notifyListeners();
  }

  Future<void> fetchMoreDriver() async {
    final more = (await _driverAdminService.fetchMoreDriver())!;
    if (more.isNotEmpty) {
      drivers.addAll(more);
    }
    notifyListeners();
  }

  Future<bool> update({
    required String id,
    required String licenseNumber,
    required String carNumber,
    File? carImage,
  }) async {
    try {
      final success = await _driverAdminService.update(
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

  void filterByTypeCar(String type) {
    if (type == 'All') {
      drivers = _allDriver;
    } else {
      drivers = _allDriver.where((b) => b.typecar == type).toList();
    }
    notifyListeners();
  }

  void sortDriverByName(String type) {
    switch (type) {
      case 'asc':
        ascDriverByName();
        break;
      case 'desc':
        descDriverByName();
        break;
      default:
        ascDriverByName();
    }
  }

  void ascDriverByName() {
    drivers.sort((a, b) => a.user.fullName.compareTo(b.user.fullName));
    notifyListeners();
  }

  void descDriverByName() {
    drivers.sort((a, b) => b.user.fullName.compareTo(a.user.fullName));
    notifyListeners();
  }

  void sortDriverByDate(String type) {
    switch (type) {
      case 'asc':
        ascDriverByDate();
        break;
      case 'desc':
        descDriverByDate();
        break;
      default:
        ascDriverByDate();
    }
  }

  void ascDriverByDate() {
    drivers.sort((a, b) => a.user.createdAt.compareTo(b.user.createdAt));
    notifyListeners();
  }

  void descDriverByDate() {
    drivers.sort((a, b) => b.user.createdAt.compareTo(a.user.createdAt));
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _debounce?.cancel();
    super.dispose();
  }
}
