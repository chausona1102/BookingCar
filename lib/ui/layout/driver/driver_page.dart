import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/shared/navigation_bar_driver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPage();
}

class _DriverPage extends State<DriverPage> {
  @override
  void initState() {
    super.initState();
    // final authManager = context.read<AuthManager>();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthManager>().user;
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/turtle_success.png',
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user != null ? 'Xin chào, ${user.fullName}' : '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DriverNavBar(),
    );
  }
}
