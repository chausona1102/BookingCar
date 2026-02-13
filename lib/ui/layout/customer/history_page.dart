import 'package:booking_app/models/booking.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/statusBadge.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'booking_manager.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<BookingModel>>? _historyFuture;
  String? userId;
  String? type;

  @override
  void initState() {
    super.initState();
    _initHistory();
  }

  Future<void> _initHistory() async {
    final user = context.read<AuthManager>().user!;
    final userId = user.id;

    if (user.role == 'customer') {
      setState(() {
        _historyFuture = context
            .read<BookingManager>()
            .fetchHistoryBookingOfUser(userId);
      });
    } else if (user.role == 'driver') {
      final driverId = await context.read<DriverManager>().getDriverIdByUserId(
        userId,
      );

      setState(() {
        _historyFuture = context
            .read<BookingManager>()
            .fetchHistoryBookingOfDriver(driverId);
      });
    }
  }

  String getTypeImage(String type) {
    switch (type) {
      case 'car':
        return 'assets/images/car.png';
      case 'motobike':
        return 'assets/images/motobike.png';
      case 'driver':
        return 'assets/images/driver.png';
      default:
        return 'assets/images/car.png';
    }
  }

  String getTypeText(String type) {
    switch (type) {
      case 'car':
        return 'Ô tô';
      case 'motobike':
        return 'Xe máy';
      case 'driver':
        return 'Tài xế';
      default:
        return 'Ô tô';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Lịch sử'),
      backgroundColor: Colors.green.shade50,
      body: FutureBuilder(
        future: _historyFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(child: Text('Có lỗi xảy ra'));
          }

          final history = snap.data ?? [];
          if (history.isEmpty) {
            return const Center(child: Text('Trống'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final booking = history[index];
              type = booking.type;
              return Padding(
                padding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 5,
                  vertical: 3,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            getTypeImage(booking.type),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${booking.bookingTimeFormatted}',
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${MyFunctions().convertToVND(booking.price.toInt().toString())}đ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  getTypeText(type!),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        StatusBadge(booking.status),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // bottomNavigationBar: DriverNavBar(),
    );
  }
}
