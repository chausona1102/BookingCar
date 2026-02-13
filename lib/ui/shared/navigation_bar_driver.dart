import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../notifications/notification_manager.dart';

class DriverNavBar extends StatelessWidget {
  const DriverNavBar({super.key});
  @override
  Widget build(BuildContext context) {
    final notiCount = context.watch<NotificationManager>().unreadCount;
    return BottomAppBar(
      height: 65,
      color: Color(0xFF1E1E1E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(
              Icons.directions_car,
              color: Colors.green,
              size: 26,
            ),
            onPressed: () {
              context.push('/bookings-request');
            },
          ),
          IconButton(
            onPressed: () {
              context.push('/notifications');
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications, color: Colors.green, size: 26),
                if (notiCount > 0)
                  Positioned(
                    right: -2,
                    top: -12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$notiCount',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.green, size: 26),
            onPressed: () {
              context.push('/');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.history_sharp,
              color: Colors.green,
              size: 26,
            ),
            onPressed: () {
              context.push('/history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.green, size: 26),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
    );
  }
}
