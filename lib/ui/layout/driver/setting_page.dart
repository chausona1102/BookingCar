import 'package:booking_app/models/driver.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  final String? userId;
  const SettingPage({super.key, required this.userId});
  @override
  createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Driver? driver;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDriver();
  }

  Future<void> _loadDriver() async {
    if (widget.userId == null) return;

    final result = await context.read<DriverManager>().fetchDriverByUserId(
      userId: widget.userId!,
    );

    if (!mounted) return;

    setState(() {
      driver = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final driverManager = context.watch<DriverManager>();
    if (isLoading) {
      return Scaffold(
        appBar: myAppBar(context, 'Cài đặt'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (driver == null) {
      return Scaffold(
        appBar: myAppBar(context, 'Cài đặt'),
        body: const Center(child: Text('Không tìm thấy tài xế')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: myAppBar(context, 'Cài đặt'),
      body: isLandScape
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _avatar(driver!.user.avatarUrl, 'medium'),
                const SizedBox(height: 10),
                _info(driver!, driverManager),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _avatar(driver!.user.avatarUrl, 'large'),
                const SizedBox(height: 20),
                _info(driver!, driverManager),
              ],
            ),
    );
  }

  Widget _avatar(avatar, size) {
    double _size = 70;
    switch (size) {
      case 'small':
        _size = 70;
        break;
      case 'medium':
        _size = 80;
        break;
      case 'large':
        _size = 100;
        break;
      default:
        _size = 70;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Image.network(
            avatar,
            width: _size,
            height: _size,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _info(Driver driver, DriverManager driverManager) {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 5, left: 5, bottom: 5, right: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: const Color.fromARGB(255, 196, 195, 195),
          child: Row(
            children: [
              Image.asset('assets/images/setting.png', width: 70),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Bật chế độ online',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              Switch(
                value: driver.isonline,
                activeColor: Colors.green,
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.green,
                inactiveThumbColor: Colors.black45,
                // inactiveTrackColor: Colors.white,
                onChanged: (value) async {
                  setState(() {
                    driver.isonline = value;
                  });
                  final update = await driverManager.updateIsOnline(driver.id);
                  if (!update) {
                    setState(() {
                      driver.isonline = !value;
                    });
                    snackBarLogger(context, 'Cập nhật thất bại!', 'error');
                  } else {
                    if (value) {
                      snackBarLogger(context, 'Đã online', 'success');
                    } else {
                      snackBarLogger(context, 'Đã offline', 'success');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
