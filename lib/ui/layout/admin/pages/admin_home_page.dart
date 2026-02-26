import 'package:booking_app/models/actionitems.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  User? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = context.read<AuthManager>().currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(user),
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
    );
  }

  Widget _buildHeader(User? user) {
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
              border: Border.all(color: const Color(0xFF00C853), width: 2.5),
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
              color: const Color(0xFF00C853).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00C853), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(
                //   width: 7,
                //   height: 7,
                //   decoration: BoxDecoration(
                //     color: const Color(0xFF00C853),
                //     shape: BoxShape.circle,
                //   ),
                // ),
                Container(
                  child: Icon(Icons.admin_panel_settings, color: Colors.green),
                ),
                const SizedBox(width: 6),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: const Color(0xFF00C853),
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
        subtitle: 'Quản lý đơn hàng',
        color: const Color(0xFF1565C0),
        onTap: () => context.push('/bookings-manager'),
      ),
      ActionItem(
        image: 'assets/images/user.png',
        label: 'Người dùng',
        subtitle: 'Quản lý người dùng',
        color: const Color(0xFF00C853),
        onTap: () => context.push('/users-manager'),
      ),
      ActionItem(
        image: 'assets/images/driver.png',
        label: 'Tài xế',
        subtitle: 'Quản lý tài xế',
        color: const Color(0xFFE65100),
        onTap: () => context.push('/drivers-manager'),
      ),
      ActionItem(
        image: 'assets/images/request.png',
        label: 'Đơn đăng ký',
        subtitle: 'Đơn đăng ký làm tài xế',
        color: const Color(0xFF6A1B9A),
        onTap: () => context.push('/driver-request-manager'),
      ),
      ActionItem(
        image: 'assets/images/diagram.png',
        label: 'Thống kê',
        subtitle: 'Thông kê doanh thu',
        color: const Color(0xFFE65100),
        onTap: () => context.push('/statistical'),
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
