import 'package:booking_app/models/driver.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/driverAppBar.dart';
import 'package:booking_app/ui/shared/headerAppbar.dart';
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
    final driverManager = context.watch<DriverManager>();

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1923),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00C853)),
        ),
      );
    }

    if (driver == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        appBar: driverAppBar('Cài đặt'),
        body: const Center(
          child: Text(
            'Không tìm thấy tài xế',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: Column(
        children: [
          buildHeader(context, 'Cài đặt'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _sectionLabel('Trạng thái hoạt động'),
                  const SizedBox(height: 10),
                  _buildOnlineToggle(driver!, driverManager),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildOnlineToggle(Driver driver, DriverManager driverManager) {
    final isOnline = driver.isonline;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? const Color(0xFF00C853) : Colors.grey)
                .withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isOnline ? const Color(0xFF00C853) : Colors.grey.shade400)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: isOnline ? const Color(0xFF00C853) : Colors.grey.shade400,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chế độ online',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F1923),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isOnline ? 'Đang nhận chuyến mới' : 'Không nhận chuyến mới',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline
                        ? const Color(0xFF00C853)
                        : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: isOnline,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF00C853),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (value) async {
              setState(() => driver.isonline = value);
              final ok = await driverManager.updateIsOnline(driver.id);
              if (!ok) {
                setState(() => driver.isonline = !value);
                snackBarLogger(context, 'Cập nhật thất bại!', 'error');
              } else {
                snackBarLogger(
                  context,
                  value ? 'Đã online' : 'Đã offline',
                  'success',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
