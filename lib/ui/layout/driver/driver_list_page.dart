import 'package:booking_app/models/membership.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/auth/customer_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/myappbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/navigation_bar.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:go_router/go_router.dart';

class DriverListPage extends StatefulWidget {
  const DriverListPage({super.key});
  @override
  State<DriverListPage> createState() => _DriverListPage();
}

class _DriverListPage extends State<DriverListPage> {
  Membership? _membership;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      context.read<DriverManager>().fetchDrivers();
      final authManager = context.read<AuthManager>();
      final customerManager = context.read<CustomerManager>();
      final userId = authManager.currentUserId;
      if (userId != null) {
        try {
          final record = await customerManager.getMembership(user: userId);
          if (!mounted) return;
          if (record != null) {
            setState(() {
              _membership = record;
            });
            print(record);
          }
        } catch (e) {
          print('Lỗi $e');
        }
      } else {
        context.push('/login');
        print('Không tìm thấy userId');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthManager>().user;
    final manager = context.watch<DriverManager>();
    return Scaffold(
      appBar: myAppBar(context, "Đặt tài xế"),
      backgroundColor: Colors.green.shade50,
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 20),
        child: ListView.builder(
          itemCount: manager.drivers.length,
          itemBuilder: (context, index) {
            final driver = manager.drivers[index];
            var typeCar = 'Xe hơi';
            var licenseNumber = driver.licensenumber ?? 'Chưa có bằng lái';
            if (driver.typecar == 'car') {
              typeCar = 'Xe hơi';
            } else {
              typeCar = 'Xe máy';
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        driver.user.avatarUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Loại xe: $typeCar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black45),
                          ),
                          Text(
                            'Số hiệu bằng lái: $licenseNumber',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),
                    button('Đặt tài xế', 'success', () {
                      context.push(
                        '/booking',
                        extra: {
                          'type': 'driver',
                          'memberInfo': _membership,
                          'user': user,
                        },
                      );
                    }),
                    // TextButton(
                    //   onPressed: () {},
                    //   style: TextButton.styleFrom(
                    //     foregroundColor: Colors.green,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     side: const BorderSide(color: Colors.green),
                    //   ),
                    //   child: const Text('Đặt tài xế'),
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
