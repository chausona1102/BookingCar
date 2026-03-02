import 'dart:async';

import 'package:booking_app/models/driverrequest.dart';
import 'package:booking_app/services/admin/driver_request_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DriverRequestAdminManager extends ChangeNotifier {
  final logger = Logger();
  final DriverRequestAdminService _requestService = DriverRequestAdminService();
  List<DriverRequest> requests = [];
  Timer? _debounce;

  Future<void> fetchRequestLimit() async {
    requests = (await _requestService.fetchRequestLimit())!;
    notifyListeners();
  }

  Future<bool> updateStatusAccepted({
    required String id,
    required String status,
    required String user,
    required String licensenumber,
    required String typecar,
    required String carnumber,
    String? carImageURL,
  }) async {
    return _requestService.updateStatusAccepted(
      id: id,
      status: status,
      user: user,
      licensenumber: licensenumber,
      typecar: typecar,
      carnumber: carnumber,
      carimage: carImageURL,
    );
  }

  Future<bool> updateStatusCancelled(String id) async {
    return await _requestService.updateStatusCancelled(id);
  }

  Future<void> search(String key) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final result = await _requestService.search(key);
      requests = result ?? [];
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
