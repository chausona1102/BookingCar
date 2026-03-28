import 'package:booking_app/models/driver.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/changepasswordoverley.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/layout/lockacountverifyoverley.dart';
import 'package:booking_app/ui/shared/headerAppbar.dart';
import 'package:booking_app/ui/shared/showDialogNotif.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

class SettingPage extends StatefulWidget {
  final String? userId;
  const SettingPage({super.key, required this.userId});
  @override
  createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final logger = Logger();
  Driver? driver;
  bool isLoading = true;
  String userId = '';
  late User user;

  bool _showSecuritySub = false;

  @override
  void initState() {
    super.initState();
    userId = widget.userId ?? '';
    user = context.read<AuthManager>().currentUser!;
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
        body: Column(
          children: [
            buildHeader(context, 'Cài đặt'),
            Expanded(
              flex: 9,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _sectionLabel('bảo mật & thông tin'),
                    const SizedBox(height: 10),
                    _buildViewInfo(),
                    const SizedBox(height: 10),
                    _buildSecurity(),
                    if (_showSecuritySub) _buildSecuritySub(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
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
                  const SizedBox(height: 10),
                  _sectionLabel('bảo mật & thông tin'),
                  const SizedBox(height: 10),
                  _buildViewInfo(),
                  const SizedBox(height: 10),
                  _buildSecurity(),
                  if (_showSecuritySub) _buildSecuritySub(),
                  const SizedBox(height: 10),
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
                // ignore: deprecated_member_use
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
                  // ignore: deprecated_member_use
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
            // ignore: deprecated_member_use
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF00C853),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (value) async {
              setState(() => driver.isonline = value);
              final ok = await driverManager.updateIsOnline(driver.id);
              if (!ok) {
                setState(() => driver.isonline = !value);
                // ignore: use_build_context_synchronously
                snackBarLogger(context, 'Cập nhật thất bại!', 'error');
              } else {
                snackBarLogger(
                  // ignore: use_build_context_synchronously
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

  Widget _buildViewInfo() {
    return GestureDetector(
      onTap: () {
        context.push('/myinfo');
      },
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color.fromARGB(255, 80, 126, 99).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.info,
                color: const Color.fromARGB(255, 87, 87, 87),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F1923),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Chỉnh sửa thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF00C853),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurity() {
    return GestureDetector(
      onTap: () {
        setState(() => _showSecuritySub = !_showSecuritySub);
      },
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color.fromARGB(255, 80, 126, 99).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.lock,
                color: const Color.fromARGB(255, 87, 87, 87),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bảo mật & đăng nhập',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F1923),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Đổi mật khẩu, khóa tài khoản',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF00C853),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySub() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(top: 4, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => ChangePasswordOverlay.show(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0F1923),
              minimumSize: const Size(double.infinity, 48),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          TextButton(
            onPressed: () {
              context.read<AuthManager>().logout();
              context.go('/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade400,
              minimumSize: const Size(double.infinity, 48),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          TextButton(
            onPressed: () => LockaCountVerifyOverley.show(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade400,
              minimumSize: const Size(double.infinity, 48),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text(
              'Khóa tài khoản',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
