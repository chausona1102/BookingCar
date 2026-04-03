import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/shared/avatarCircle.dart';
import 'package:booking_app/ui/shared/navigation_bar.dart';
import 'package:booking_app/ui/shared/navigation_bar_driver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthManager>().user;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }
    final role = user.role;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLandscape
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              avatarCircle(user, 70),
                              Positioned(
                                left: 0,
                                bottom: 0,
                                top: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      context.push('/edit-info');
                                    },
                                    icon: Icon(
                                      Icons.edit_square,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _name(user),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 30),
                  Expanded(
                    flex: 7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Spacer(),
                        _cardInfo(context, user),
                        const SizedBox(height: 10),
                        _buttonLogOut(context),
                        // const Spacer(),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  const SizedBox(height: 40),
                  Stack(
                    children: [
                      avatarCircle(user, 70),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        top: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              context.push('/edit-info');
                            },
                            icon: Icon(Icons.edit_square, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _name(user),
                  const SizedBox(height: 30),
                  _cardInfo(context, user),
                  const Spacer(),
                  _buttonLogOut(context),
                ],
              ),
      ),
      bottomNavigationBar: role == 'driver' ? DriverNavBar() : NavBar(),
    );
  }

  Widget _name(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          user.fullName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _cardInfo(BuildContext context, User user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoRow(icon: Icons.person, text: user.userName),
            const Divider(),
            _infoRow(icon: Icons.email, text: user.emailText),
            const Divider(),
            _infoRow(icon: Icons.phone, text: user.phoneNumber),
            if (user.role != 'driver') ...[
              const Divider(),
              TextButton(
                onPressed: () => {context.push('/register-driver')},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: Text('Đăng ký làm tài xế'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buttonLogOut(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
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
