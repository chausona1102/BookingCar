import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/customer_service.dart';

class CustomerManager extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();
  Future<bool> addDriver({
    required String licensenumber,
    required String typecar,
    required String user,
    File? carimage,
  }) async {
    return await _customerService.addDriver(
      licensenumber: licensenumber,
      typecar: typecar,
      user: user,
      carimage: carimage,
    );
  }
  
}
