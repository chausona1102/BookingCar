import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/shared/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthManager>().user;
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// Avatar
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
            ),
            const SizedBox(height: 20),

            /// Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.fullName ?? 'Chưa có tên',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // IconButton(
                //   onPressed: () => {},
                //   icon: Icon(Icons.edit, size: 0),
                // ),
              ],
            ),

            const SizedBox(height: 30),

            /// Info card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(
                      icon: Icons.person,
                      text: user?.userName ?? 'Chưa có tài khoản',
                    ),
                    const Divider(),
                    _infoRow(
                      icon: Icons.email,
                      text: user?.emailText ?? 'Chưa có email',
                    ),
                    const Divider(),
                    _infoRow(
                      icon: Icons.phone,
                      text: user?.phoneNumber ?? 'Chưa có số điện thoại',
                    ),
                    const Divider(),

                    TextButton(
                      onPressed: () => {context.go('/register-driver')},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Đăng ký làm tài xế'),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            /// Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  context.read<AuthManager>().logout();
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _infoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
