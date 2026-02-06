import 'package:flutter/material.dart';

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
}
