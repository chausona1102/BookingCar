import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/shared/avatarCircle.dart';
import 'package:booking_app/ui/shared/headerAppbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:logger/logger.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final logger = Logger();
  late User user;
  @override
  void initState() {
    super.initState();
    user = context.read<AuthManager>().currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Column(
        children: [
          buildHeader(context, 'Thông tin cá nhân'),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                top: 20,
                left: 20,
                bottom: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF00C853).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 5,
                  right: 5,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: avatarCircle(user, 40)),
                    const SizedBox(height: 5),
                    Center(
                      child: const Text(
                        'Avatar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black45,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildRow(Icons.person_outline_outlined, user.userName),
                    const SizedBox(height: 15),
                    buildRow(Icons.person_outline_outlined, user.fullName),
                    const SizedBox(height: 15),
                    buildRow(Icons.email_outlined, user.emailText),
                    const SizedBox(height: 15),
                    buildRow(Icons.phone_outlined, user.phoneNumber),
                    const SizedBox(height: 15),
                    buildRow(Icons.face, user.getRole.toUpperCase()),
                    const SizedBox(height: 15),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.push('/edit-info');
                        },
                        child: const Text(
                          'Chỉnh sửa thông tin cá nhân',
                          style: TextStyle(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(alignment: Alignment.centerLeft, child: Icon(icon)),
          ),
          Expanded(
            flex: 8,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(255, 172, 172, 172),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
