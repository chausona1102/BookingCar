import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter/widgets.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
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
              context.push('/booking');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.green,
              size: 26,
            ),
            onPressed: () {
              context.push('/notification');
            },
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
