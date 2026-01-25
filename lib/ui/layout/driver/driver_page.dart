import 'package:booking_app/models/driver.dart';
import 'package:flutter/material.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPage();
}

class _DriverPage extends State<DriverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Driver Page",
          style: TextStyle(color: Colors.red, fontSize: 20),
        ),
      ),
    );
  }
}
