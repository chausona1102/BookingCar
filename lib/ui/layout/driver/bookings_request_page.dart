import 'package:booking_app/models/location.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/customer/booking_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:booking_app/ui/shared/iconSvg.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingsRequestPage extends StatefulWidget {
  const BookingsRequestPage({super.key});

  @override
  State<BookingsRequestPage> createState() => _BookingsRequestPage();
}

class _BookingsRequestPage extends State<BookingsRequestPage> {
  LocationModel? pickUpLocation;
  String? driverId;
  // LocationModel? dropOffLocation;
  @override
  void initState() {
    super.initState();

    _fetchDriverId();
  }

  Future<void> _fetchDriverId() async {
    // final user = context.read<AuthManager>().user!;
    final userId = context.read<AuthManager>().currentUserId;
    context.read<DriverManager>().listenBookingRequests(userId);
    // final userId = user.id;

    driverId = await context.read<DriverManager>().getDriverIdByUserId(userId!);
    print(driverId);
  }

  @override
  Widget build(BuildContext context) {
    final myFunctions = context.watch<MyFunctions>();
    final bookingManager = context.watch<BookingManager>();
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: myAppBar(context, 'Chuyến đang chờ nhận'),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 5),
        child: Consumer<DriverManager>(
          builder: (context, manager, child) {
            final bookings = manager.bookingRequests;
            // bookingManager??
            if (bookings.isEmpty) {
              return Center(
                child: Column(children: [Text('Không có đơn đặt xe nào')]),
              );
            }
            return ListView.builder(
              itemCount: bookings.length,
              // padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              itemBuilder: (_, i) {
                final pickUpLocationId = bookings[i].pickupLocationId;
                // final dropOffLocationId = bookings[i].dropoffLocationId;
                bookingManager.fetchLocation(pickUpLocationId);
                // bookingManager.fetchLocation(dropOffLocationId);

                final pickUpLocation =
                    bookingManager.locations[pickUpLocationId];
                // final dropOffLocation =
                //     bookingManager.locations[dropOffLocationId];

                return Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  myFunctions.getTypeImage(bookings[i].type),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${myFunctions.convertToVND(bookings[i].price.toInt().toString())}đ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Text('-'),
                                        const SizedBox(width: 5),
                                        Text(
                                          myFunctions.getTypeText(
                                            bookings[i].type,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      bookings[i].bookingTimeFormatted,
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              button('Nhận đơn', 'green', () async {
                                final isPending = await bookingManager
                                    .checkPending(bookings[i].id!);
                                if (isPending) {
                                  final addOke = await bookingManager
                                      .addDriverId(bookings[i].id!, driverId!);
                                  if (addOke) {
                                    snackBarLogger(
                                      context,
                                      'Bạn đã nhận đơn',
                                      'success',
                                    );
                                  } else {
                                    snackBarLogger(
                                      context,
                                      'Nhận đơn thất bại',
                                      'error',
                                    );
                                  }
                                } else {
                                  debugPrint('Khong the nhan don');
                                }
                              }),
                            ],
                          ),

                          const Divider(color: Colors.green),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              svgIcon('assets/icons/location.svg', 'red'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pickUpLocation?.placeName ??
                                      "Đang tải địa chỉ...",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // const Divider(color: Colors.green),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     svgIcon('assets/icons/location.svg', 'green'),
                          //     const SizedBox(width: 8),
                          //     Expanded(
                          //       child: Text(
                          //         dropOffLocation?.placeName ??
                          //             "Đang tải địa chỉ...",
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis,
                          //         style: const TextStyle(
                          //           fontWeight: FontWeight.w600,
                          //           fontSize: 15,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      // bottomNavigationBar: DriverNavBar(),
    );
  }
}
