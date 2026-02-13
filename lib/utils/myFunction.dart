import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyFunctions extends ChangeNotifier {
  String convertToVND(String prop) {
    final buffer = StringBuffer();
    int count = 0;

    for (int i = prop.length - 1; i >= 0; i--) {
      buffer.write(prop[i]);
      count++;
      if (i == 0) {
        break;
      }
      if (count == 3) {
        buffer.write(',');
        count = 0;
      }
    }

    return buffer.toString().split('').reversed.join();
  }

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

  String planRevert(String plan) {
    switch (plan) {
      case 'silver':
        return 'Bạc';
      case 'gold':
        return 'Vàng';
      case 'platinum':
        return 'Bạch Kim';
      default:
        return 'Không có';
    }
  }
  

  String getTypeImage(String type) {
    switch (type) {
      case 'car':
        return 'assets/images/car.png';
      case 'motobike':
        return 'assets/images/motobike.png';
      case 'driver':
        return 'assets/images/driver.png';
      default:
        return 'assets/images/car.png';
    }
  }

  String getTypeText(String type) {
    switch (type) {
      case 'car':
        return 'Ô tô';
      case 'motobike':
        return 'Xe máy';
      case 'driver':
        return 'Tài xế';
      default:
        return 'Ô tô';
    }
  }

  String getTextStatus(String status) {
    switch (status) {
      case 'pendding':
        return 'Đang chờ';
      case 'accepted':
        return 'Tài xế đang đến';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'ontrip':
        return 'Đang trong chuyến đi';
      default:
        return 'Đang chờ';
    }
  }
}
