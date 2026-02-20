import 'package:booking_app/models/booking.dart';
import 'package:booking_app/ui/layout/customer/payment_manager.dart';
import 'package:booking_app/ui/layout/customer/become_driver_page.dart';
import 'package:booking_app/ui/layout/customer/become_vip_member_page.dart';
import 'package:booking_app/ui/layout/customer/booking_manager.dart';
import 'package:booking_app/ui/layout/customer/payment_success.dart';
import 'package:booking_app/ui/layout/customer/trip_tracing_page.dart';
import 'package:booking_app/ui/layout/driver/bookings_request_page.dart';
import 'package:booking_app/ui/layout/driver/driver_list_page.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/layout/customer/booking_page.dart';
import 'package:booking_app/ui/layout/customer/history_page.dart';
import 'package:booking_app/ui/layout/customer/payment_page.dart';
import 'package:booking_app/ui/layout/driver/driver_page.dart';
import 'package:booking_app/ui/auth/customer_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_trip_tracking_page.dart';
import 'package:booking_app/ui/layout/driver/payment_trip_page.dart';
import 'package:booking_app/ui/layout/driver/setting_page.dart';
import 'package:booking_app/ui/layout/edit_info_page.dart';
import 'package:booking_app/ui/layout/profile.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:booking_app/models/vipdata.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './ui/auth/login_page.dart';
import './ui/layout/customer/customer_page.dart';
import './ui/auth/auth_manager.dart';
import 'ui/auth/register.dart';
import './ui/notifications/notification_manager.dart';
import './ui/notifications/notification_page.dart';
import 'package:booking_app/ui/splash/splash_page.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthManager()),
        ChangeNotifierProvider(create: (_) => CustomerManager()),
        ChangeNotifierProvider(create: (_) => PaymentManager()),
        ChangeNotifierProvider(create: (_) => DriverManager()),
        ChangeNotifierProvider(create: (_) => BookingManager()),
        ChangeNotifierProvider(create: (_) => MyFunctions()),
        ChangeNotifierProvider(create: (_) => NotificationManager()),
      ],
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
  // late String? role = 'user';
  @override
  void initState() {
    super.initState();

    context.read<AuthManager>().restoreLogin();

    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: context.read<AuthManager>(),
      redirect: (context, state) {
        final auth = context.read<AuthManager>();
        final loggedIn = auth.isLoggedIn;
        final _role = auth.user?.role;
        final loggingIn = state.matchedLocation == '/login';
        final registering = state.matchedLocation == '/register';
        final splashing = state.matchedLocation == '/splash';

        if (splashing) return null;

        if (!loggedIn && !loggingIn && !registering) {
          return '/login';
        }

        if (loggedIn && (loggingIn || registering)) {
          return _role == 'driver' ? '/driver-page' : '/';
        }

        if (loggedIn && _role == 'driver' && state.matchedLocation == '/') {
          return '/driver-page';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/', builder: (_, __) => Customer()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const Register()),
        GoRoute(path: '/profile', builder: (_, __) => const Profile()),
        GoRoute(
          path: '/register-driver',
          builder: (_, __) => const BecomeDriverPage(),
        ),
        GoRoute(
          path: '/driver-list',
          builder: (_, __) => const DriverListPage(),
        ),
        GoRoute(path: '/driver-page', builder: (_, __) => const DriverPage()),
        GoRoute(
          path: '/become-vip-page',
          builder: (_, __) => const BecomeVipMemberPage(),
        ),
        GoRoute(
          path: '/payment-page',
          builder: (context, state) {
            final data = state.extra as Vipdata;
            return PaymentPage(data: data);
          },
        ),
        GoRoute(
          path: '/payment-success',
          builder: (_, __) {
            return PaymentSuccessPage();
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, __) {
            return NotificationPage();
          },
        ),
        GoRoute(
          path: '/booking',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return BookingPage(data: data);
          },
        ),
        GoRoute(
          path: '/trip-tracing',
          builder: (_, __) {
            return TripTracingPage();
          },
        ),
        GoRoute(
          path: '/history',
          builder: (_, __) {
            return HistoryPage();
          },
        ),
        GoRoute(
          path: '/bookings-request',
          builder: (_, __) {
            return BookingsRequestPage();
          },
        ),
        GoRoute(
          path: '/driver-trip',
          builder: (_, __) {
            return DriverTripTrackingPage();
          },
        ),
        GoRoute(
          path: '/setting',
          builder: (context, state) {
            final data = state.extra as String;
            return SettingPage(userId: data);
          },
        ),
        GoRoute(
          path: '/payment-trip-page',
          builder: (context, state) {
            final data = state.extra as BookingModel;
            return PaymentTripPage(data: data);
          },
        ),
        GoRoute(
          path: '/edit-info',
          builder: (_, __) {
            return EditInfoPage();
          },
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
