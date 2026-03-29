import 'package:booking_app/models/driver.dart';
import 'package:booking_app/models/location.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/customer/booking_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/notifications/notification_manager.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:booking_app/ui/shared/iconSvg.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class BookingsRequestPage extends StatefulWidget {
  const BookingsRequestPage({super.key});

  @override
  State<BookingsRequestPage> createState() => _BookingsRequestPageState();
}

class _BookingsRequestPageState extends State<BookingsRequestPage> {
  String? driverId;
  String? userId;
  Driver? driver;
  final logger = Logger();
  late DriverManager _driverManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _driverManager = context.read<DriverManager>();
  }

  @override
  void initState() {
    super.initState();
    _fetchDriverId();
  }

  @override
  void dispose() {
    _driverManager.disposeBookingListener();
    super.dispose();
  }

  Future<void> _fetchDriverId() async {
    userId = context.read<AuthManager>().currentUserId;
    context.read<DriverManager>().listenBookingRequests(userId);
    if (userId != null) {
      driver = await context.read<DriverManager>().fetchDriverByUserId(
        userId: userId!,
      );
      driverId = driver?.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myFunctions = context.watch<MyFunctions>();
    final bookingManager = context.watch<BookingManager>();
    final notiManager = context.watch<NotificationManager>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: myAppBar(context, 'Chuyến đang chờ nhận'),
      body: Consumer<DriverManager>(
        builder: (context, manager, child) {
          final bookings = manager.bookingRequests;

          if (bookings.isEmpty) {
            return const Center(child: Text('Không có đơn đặt xe nào'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (_, i) {
              final booking = bookings[i];
              final pickUpLocation = booking.pickupLocation;
              final dropOffLocation = booking.dropoffLocation;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isLandscape
                      ? _buildLandscapeItem(
                          booking,
                          pickUpLocation,
                          dropOffLocation,
                          myFunctions,
                          notiManager,
                          bookingManager,
                        )
                      : _buildPortraitItem(
                          booking,
                          pickUpLocation,
                          dropOffLocation,
                          myFunctions,
                          bookingManager,
                          notiManager,
                          // userId,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLandscapeItem(
    booking,
    LocationModel? pickUpLocation,
    LocationModel? dropOffLocation,
    MyFunctions myFunctions,
    NotificationManager notiManager,
    BookingManager bookingManager,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // IMAGE
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: booking.driver != null
              ? Image.network(
                  booking.driver.user.avatarUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  myFunctions.getTypeImage(booking.type),
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
        ),

        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${myFunctions.convertToVND(booking.price.toInt().toString())}đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    ' - ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    myFunctions.getTypeText(booking.type),
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                booking.bookingTimeFormatted,
                style: const TextStyle(color: Colors.black45),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (booking.driver != null) ...[
                Row(
                  children: [
                    svgIcon('assets/icons/driver.svg', 'green', false),
                    Text(
                      "Yêu cầu: ${booking.driver.user.fullName}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.green, thickness: 2),
              ],
              Row(
                children: [
                  svgIcon('assets/icons/location.svg', 'red', false),
                  Text(
                    pickUpLocation?.placeName ?? "Đang tải...",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.green, thickness: 2),
              Row(
                children: [
                  svgIcon('assets/icons/location.svg', 'green', false),
                  Text(
                    dropOffLocation?.placeName ?? "Đang tải...",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),
        button('Nhận đơn', 'green', () async {
          final isPending = await bookingManager.checkPending(booking.id!);
          final onTrip = await context.read<DriverManager>().checkOnTrip(
            driverId!,
          );
          if (booking.driver != null) {
            if (driverId != booking.driver.id) {
              snackBarLogger(context, 'Đây không phải đơn của bạn', 'warning');
              return;
            }
          }
          if (onTrip) {
            snackBarLogger(context, 'Bạn đang trong chuyến xe khác', 'warning');
            return;
          }
          if ((booking.type != driver!.typecar) && booking.type != 'driver') {
            snackBarLogger(context, 'Loại xe không phù hợp', 'warning');
            return;
          }
          if (isPending) {
            final addOke = await bookingManager.addDriverId(
              booking.id!,
              driverId!,
            );

            if (addOke) {
              context.push(
                '/driver-trip',
                extra: {'booking': booking, 'driverid': driverId},
              );
              snackBarLogger(context, 'Bạn đã nhận đơn', 'success');
              notiManager.addNotification(
                'Thông báo từ hệ thống',
                'success',
                'Bạn đã nhận đơn hàng',
                userId!,
              );
            }
          }
        }),
      ],
    );
  }

  Widget _buildPortraitItem(
    booking,
    LocationModel? pickUpLocation,
    LocationModel? dropOffLocation,
    MyFunctions myFunctions,
    BookingManager bookingManager,
    NotificationManager notiManager,
    // String? userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: booking.driver != null
                  ? Image.network(
                      booking.driver.user.avatarUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      myFunctions.getTypeImage(booking.type),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${myFunctions.convertToVND(booking.price.toInt().toString())}đ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    booking.bookingTimeFormatted,
                    style: const TextStyle(color: Colors.black45),
                  ),
                ],
              ),
            ),
            button('Nhận đơn', 'green', () async {
              final isPending = await bookingManager.checkPending(booking.id!);
              final onTrip = await context.read<DriverManager>().checkOnTrip(
                driverId!,
              );
              if (booking.driver != null) {
                if (driverId != booking.driver.id) {
                  snackBarLogger(
                    context,
                    'Đây không phải đơn của bạn',
                    'warning',
                  );
                  return;
                }
              }

              if (onTrip) {
                snackBarLogger(
                  context,
                  'Bạn đang trong chuyến xe khác',
                  'warning',
                );
                return;
              }
              if ((booking.type != driver!.typecar) &&
                  booking.type != 'driver') {
                snackBarLogger(context, 'Loại xe không phù hợp', 'warning');
                return;
              }
              if (isPending) {
                final addOke = await bookingManager.addDriverId(
                  booking.id!,
                  driverId!,
                );

                if (addOke) {
                  context.push(
                    '/driver-trip',
                    extra: {'booking': booking, 'driverid': driverId},
                  );
                  snackBarLogger(context, 'Bạn đã nhận đơn', 'success');
                  notiManager.addNotification(
                    'Thông báo từ hệ thống',
                    'success',
                    'Bạn đã nhận đơn hàng',
                    userId!,
                  );
                }
              }
            }),
          ],
        ),
        if (booking.driver != null) ...[
          const Divider(color: Colors.green, thickness: 2),
          Row(
            children: [
              svgIcon('assets/icons/driver.svg', 'green', false),
              Text(
                "Yêu cầu: ${booking.driver.user.fullName}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
        const Divider(color: Colors.green, thickness: 2),
        Row(
          children: [
            svgIcon('assets/icons/location.svg', 'red', false),
            Text(
              pickUpLocation?.placeName ?? "Đang tải...",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            svgIcon('assets/icons/location.svg', 'green', false),
            Text(
              dropOffLocation?.placeName ?? "Đang tải...",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
