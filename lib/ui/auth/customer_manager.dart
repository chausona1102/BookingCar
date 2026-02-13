import 'package:booking_app/models/membership.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/customer_service.dart';

class CustomerManager extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();
  Future<bool> addDriverRequest({
    required String licensenumber,
    required String typecar,
    required String user,
    File? carimage,
    required String carnumber,
  }) async {
    return await _customerService.addDriverRequest(
      licensenumber: licensenumber,
      typecar: typecar,
      user: user,
      carimage: carimage,
      carnumber: carnumber,
    );
  }

  // Future<bool> hasMembership({required String user}) async {
  //   return await _customerService.hasMembership(user);
  // }
  Future<Membership> getMembership({required String user}) async {
    final m = await _customerService.getCurrentMembership(user);

    if (m == null) {
      throw Exception('User chưa có membership');
    }

    return m;
  }
}
