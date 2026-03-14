import 'dart:async';

import 'package:booking_app/models/driverrequest.dart';
import 'package:booking_app/services/admin/driver_request_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DriverRequestAdminManager extends ChangeNotifier {
  final logger = Logger();
  final DriverRequestAdminService _requestService = DriverRequestAdminService();
  List<DriverRequest> requests = [];
  List<DriverRequest> _allRequests = [];
  Timer? _debounce;

  bool isMax = false;
  int maxLength = 0;

  Future<void> fetchRequestLimit() async {
    _allRequests = (await _requestService.fetchRequestLimit())!;
    requests = _allRequests;
    notifyListeners();
  }

  Future<void> fetchMoreRequest() async {
    final more = (await _requestService.fetchMoreRequest())!;
    if (more.isNotEmpty) {
      requests.addAll(more);
    } else {
      isMax = true;
      maxLength = requestLength;
    }
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

  void filterByStatus(String status) {
    if (status == 'All') {
      requests = _allRequests;
    } else {
      requests = _allRequests.where((b) => b.getStatus == status).toList();
    }
    notifyListeners();
  }

  void sortRequestByName(String type) {
    switch (type) {
      case 'asc':
        ascRequestByName();
        break;
      case 'desc':
        descRequestByName();
        break;
      default:
        ascRequestByName();
    }
  }

  void ascRequestByName() {
    requests.sort((a, b) => a.user.fullName.compareTo(b.user.fullName));
    notifyListeners();
  }

  void descRequestByName() {
    requests.sort((a, b) => b.user.fullName.compareTo(a.user.fullName));
    notifyListeners();
  }

  void sortRequestByDate(String type) {
    switch (type) {
      case 'asc':
        ascRequestByDate();
        break;
      case 'desc':
        descRequestByDate();
        break;
      default:
        ascRequestByDate();
    }
  }

  void ascRequestByDate() {
    requests.sort((a, b) => a.createDate.compareTo(b.createDate));
    notifyListeners();
  }

  void descRequestByDate() {
    requests.sort((a, b) => b.createDate.compareTo(a.createDate));
    notifyListeners();
  }

  int get requestLength => _allRequests.length;
  bool get isMaxLength => isMax;
  int get getMaxLength => maxLength;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
