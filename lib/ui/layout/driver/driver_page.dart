import 'package:booking_app/models/driver.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/navigation_bar_driver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:booking_app/models/actionitems.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPage();
}

class _DriverPage extends State<DriverPage> {
  @override
  void initState() {
    super.initState();
    final authManager = context.read<AuthManager>();
    final user = authManager.user;
    if (user != null) {
      context.read<DriverManager>().getDriverIdByUserId(user.id).then((
        driverId,
      ) {
        if (driverId.isNotEmpty) {
          context.read<DriverManager>().listenDriverOnline(driverId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverManager = context.watch<DriverManager>();
    final driver = driverManager.driver;
    final user = context.read<AuthManager>().user;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (driver == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1923),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00C853)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: Column(
        children: [
          _buildHeader(user, driver),
          Expanded(
            child: SingleChildScrollView(
              padding: isLandscape
                  ? const EdgeInsets.fromLTRB(20, 0, 20, 20)
                  : const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildQuickActions(context, user)],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DriverNavBar(),
    );
  }

  Widget _buildHeader(User? user, Driver driver) {
    final isOnline = driver.isonline;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1923),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 20,
        24,
        28,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E2D3D),
              border: Border.all(
                color: isOnline
                    ? const Color(0xFF00C853)
                    : Colors.grey.shade600,
                width: 2.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/turtle_success.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào 👋',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.fullName ?? 'Tài xế',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF00C853).withOpacity(0.15)
                  : Colors.red.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOnline ? const Color(0xFF00C853) : Colors.red.shade400,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? const Color(0xFF00C853)
                        : Colors.red.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline
                        ? const Color(0xFF00C853)
                        : Colors.red.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, User? user) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final actions = [
      ActionItem(
        image: 'assets/images/list.png',
        label: 'Đơn hàng',
        subtitle: 'Xem yêu cầu mới',
        color: const Color(0xFF1565C0),
        onTap: () => context.push('/bookings-request'),
      ),
      ActionItem(
        image: 'assets/images/car_driving_removebg.png',
        label: 'Theo dõi',
        subtitle: 'Chuyến hiện tại',
        color: const Color(0xFF00C853),
        onTap: () => context.push('/driver-trip'),
      ),
      ActionItem(
        image: 'assets/images/history.png',
        label: 'Lịch sử',
        subtitle: 'Các chuyến đã đi',
        color: const Color(0xFFE65100),
        onTap: () => context.push('/history'),
      ),
      ActionItem(
        image: 'assets/images/driver.png',
        label: 'Cá nhân',
        subtitle: 'Thông tin tài xế',
        color: const Color(0xFF6A1B9A),
        onTap: () => context.push('/profile'),
      ),
      ActionItem(
        image: 'assets/images/setting.png',
        label: 'Cài đặt',
        subtitle: 'Tùy chỉnh app',
        color: const Color(0xFF37474F),
        onTap: () => context.push('/setting', extra: user?.id),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLandscape ? 4 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) =>
          _buildActionCard(actions[index], isLandscape),
    );
  }

  Widget _buildActionCard(ActionItem item, bool isLandscape) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isLandscape ? 70 : 48,
              height: isLandscape ? 70 : 48,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(item.image, fit: BoxFit.contain),
              ),
            ),
            const Spacer(),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F1923),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
