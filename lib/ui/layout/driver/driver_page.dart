import 'package:booking_app/models/driver.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/iconButton.dart';
import 'package:booking_app/ui/shared/navigation_bar_driver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPage();
}

class _DriverPage extends State<DriverPage> {
  late final User? user;
  late final String? userId;
  @override
  void initState() {
    super.initState();

    final authManager = context.read<AuthManager>();
    final user = authManager.user;

    if (user != null) {
      final driverManager = context.read<DriverManager>();

      driverManager.getDriverIdByUserId(user.id).then((driverId) {
        if (driverId.isNotEmpty) {
          driverManager.listenDriverOnline(driverId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverManager = context.watch<DriverManager>();
    final driver = driverManager.driver;
    final user = context.read<AuthManager>().user;

    if (driver == null) {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }
    final isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        child: isLandScape
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  _welcomSlogan(user),
                  _actionToLive(driver),
                  SizedBox(width: 500, child: _action(context, 'large', user)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  _welcomSlogan(user),
                  const SizedBox(height: 20),
                  _actionToLive(driver),
                  const SizedBox(height: 20),
                  SizedBox(width: 500, child: _action(context, 'medium', user)),
                ],
              ),
      ),
      bottomNavigationBar: DriverNavBar(),
    );
  }

  Widget _welcomSlogan(user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 20),
        Image.asset('assets/images/turtle_success.png', width: 70, height: 70),
        const SizedBox(width: 10),
        Text(
          user != null ? 'Xin chào, ${user.fullName}' : '',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _actionToLive(Driver driver) {
    bool isOnline = driver.isonline;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Trạng thái: ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (isOnline) ...[
          Text(
            'Online',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
        if (!isOnline) ...[
          Text(
            'Offline',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _action(BuildContext context, String size, user) {
    double _spacing = 20;
    switch (size) {
      case 'small':
        _spacing = 20;
        break;
      case 'medium':
        _spacing = 30;
        break;
      case 'large':
        _spacing = 40;
        break;
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: _spacing,
      runSpacing: 20,
      children: [
        IconButton(
          onPressed: () => context.push('/bookings-request'),
          icon: iconButton(
            imagePath: 'assets/images/list.png',
            text: 'Đơn hàng',
            size: size,
          ),
        ),
        IconButton(
          onPressed: () => context.push('/driver-trip'),
          icon: iconButton(
            imagePath: 'assets/images/car_driving_removebg.png',
            text: 'Đang vận',
            size: size,
          ),
        ),
        IconButton(
          onPressed: () => context.push('/history'),
          icon: iconButton(
            imagePath: 'assets/images/history.png',
            text: 'Lịch sử',
            size: size,
          ),
        ),
        IconButton(
          onPressed: () => context.push('/profile'),
          icon: iconButton(
            imagePath: 'assets/images/driver.png',
            text: 'Cá nhân',
            size: size,
          ),
        ),
        IconButton(
          onPressed: () => context.push('/setting', extra: user.id),
          icon: iconButton(
            imagePath: 'assets/images/setting.png',
            text: 'Cài đặt',
            size: size,
          ),
        ),
      ],
    );
  }
}
