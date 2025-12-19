import 'package:booking_app/ui/layout/customer/become_driver_page.dart';
import 'package:booking_app/ui/layout/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import './ui/auth/login_page.dart';
import './ui/layout/customer/customer.dart';
import './ui/auth/auth_manager.dart';
import 'ui/auth/register.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthManager())],
      child: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    context.read<AuthManager>().restoreLogin();

    _router = GoRouter(
      redirect: (context, state) {
        final auth = context.read<AuthManager>();
        final loggedIn = auth.isLoggedIn ?? false;

        final loggingIn = state.matchedLocation == '/login';
        final registering = state.matchedLocation == '/register';

        if (!loggedIn && !loggingIn && !registering) return '/login';
        if (loggedIn && (loggingIn || registering)) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Customer()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/profile', builder: (_, __) => const Profile()),
        GoRoute(path: '/register', builder: (_, __) => const Register()),
        GoRoute(
          path: '/register-driver',
          builder: (_, __) => const BecomeDriverPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Booking Car',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
