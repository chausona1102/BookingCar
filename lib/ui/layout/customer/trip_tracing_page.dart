import 'package:booking_app/models/driver.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/customer/booking_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/iconSvg.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/showDialog.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import '../../../utils/myFunction.dart';

class TripTracingPage extends StatefulWidget {
  const TripTracingPage({super.key});

  @override
  State<TripTracingPage> createState() => _TripTracingState();
}

class _TripTracingState extends State<TripTracingPage> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  Driver? driver;
  bool _cameraMoved = false;
  final logger = Logger();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthManager>();
      final bookingManager = context.read<BookingManager>();

      final userId = auth.currentUserId;
      if (userId != null) {
        bookingManager.listenCurrentBooking(userId);
      }
    });
  }

  Future<void> _drawRoute({required LatLng from, required LatLng to}) async {
    final polylinePoints = PolylinePoints();
    final apiKey = dotenv.env['API_KEY']!;

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isEmpty) return;

    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.green,
          width: 5,
          points: result.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
        ),
      };
    });
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Đang chờ...';
      case 'accepted':
        return 'Tài xế đang đến';
      case 'completed':
        return 'Đến đích';
      case 'ontrip':
        return 'Đang trên chuyến xe';
      case 'cancelled':
        return 'Chuyến xe bị hủy';
      default:
        return 'Đang chờ...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingManager>().currentBooking;
    final bookingManager = context.read<BookingManager>();
    final driverManager = context.read<DriverManager>();
    final myFunctions = context.watch<MyFunctions>();

    return Scaffold(
      appBar: myAppBar(context, 'Theo dõi cuốc xe'),
      body: Column(
        children: [
          Expanded(
            child: booking == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/turtle_warning.png',
                          height: 120,
                        ),
                        Text(
                          'Bạn chưa đặt xe',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  )
                : FutureBuilder(
                    key: ValueKey('${booking.id}_${booking.status}'),
                    future: Future.wait([
                      bookingManager.getLocationById(
                        id: booking.pickupLocationId,
                      ),
                      bookingManager.getLocationById(
                        id: booking.dropoffLocationId,
                      ),
                    ]),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final pickup = snap.data![0]!;
                      final dropoff = snap.data![1]!;

                      final pickupName = pickup.placeName;
                      final dropoffName = dropoff.placeName;
                      final amountDistance = booking.price;
                      final statusText = _mapStatus(booking.status);

                      final pickupLatLng = LatLng(
                        double.parse(pickup.latitude),
                        double.parse(pickup.longitude),
                      );

                      final dropoffLatLng = LatLng(
                        double.parse(dropoff.latitude),
                        double.parse(dropoff.longitude),
                      );

                      return Column(
                        children: [
                          SizedBox(
                            height: 350,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: pickupLatLng,
                                zoom: 15,
                              ),
                              polylines: _polylines,
                              onMapCreated: (controller) async {
                                if (_cameraMoved) return;
                                _cameraMoved = true;

                                await _drawRoute(
                                  from: pickupLatLng,
                                  to: dropoffLatLng,
                                );
                                _mapController = controller;
                              },
                              markers: {
                                Marker(
                                  markerId: const MarkerId('pickup'),
                                  position: pickupLatLng,
                                  infoWindow: const InfoWindow(
                                    title: 'Điểm đón',
                                  ),
                                ),
                                Marker(
                                  markerId: const MarkerId('dropoff'),
                                  position: dropoffLatLng,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen,
                                  ),
                                  infoWindow: const InfoWindow(
                                    title: 'Điểm đến',
                                  ),
                                ),
                              },
                            ),
                          ),

                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(12),
                              child: Card(
                                // color: Colors.red,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsGeometry.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: const Text(
                                          'Thông tin cuốc xe',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      _infoRow(
                                        icon: 'assets/icons/location.svg',
                                        iconColor: 'red',
                                        title: 'Điểm đón',
                                        value: pickupName,
                                      ),

                                      const SizedBox(height: 12),

                                      _infoRow(
                                        icon: 'assets/icons/location.svg',
                                        iconColor: 'green',
                                        title: 'Điểm đến',
                                        value: dropoffName,
                                      ),

                                      const SizedBox(height: 12),

                                      FutureBuilder<Driver?>(
                                        future: driverManager.fetchDriverById(
                                          id: booking.driverId,
                                        ),
                                        builder: (context, snap) {
                                          if (snap.connectionState ==
                                              ConnectionState.waiting) {
                                            return _infoRow(
                                              icon: 'assets/icons/driver.svg',
                                              iconColor: 'black',
                                              title: 'Tài xế',
                                              value: 'Đang tải...',
                                            );
                                          }

                                          if (!snap.hasData ||
                                              snap.data == null) {
                                            return _infoRow(
                                              icon: 'assets/icons/driver.svg',
                                              iconColor: 'black',
                                              title: 'Tài xế',
                                              value: 'Chưa có tài xế',
                                            );
                                          }

                                          final driver = snap.data!;
                                          return Column(
                                            children: [
                                              _infoRow(
                                                icon: 'assets/icons/driver.svg',
                                                iconColor: 'black',
                                                title: 'Tài xế',
                                                value: driver.user.fullName,
                                              ),
                                              const SizedBox(height: 12),
                                              _infoRow(
                                                icon: 'assets/icons/car.svg',
                                                iconColor: 'black',
                                                title: 'Biển số',
                                                value: driver.carnumber,
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                      const Divider(height: 32),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Tổng tiền',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${myFunctions.convertToVND(amountDistance.toInt().toString())} ₫',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      Row(
                                        children: [
                                          const Text(
                                            'Trạng thái',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          _statusBadge(statusText),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: TextButton(
                                          onPressed: () async {
                                            final confirm = await showMyDialog(
                                              context,
                                              'Hủy chuyến',
                                              'Xác nhận chắc chắn hủy chuyến',
                                              'assets/images/turtle_warning.png',
                                            );
                                            if (confirm != true) return;
                                            final cancelled =
                                                await bookingManager
                                                    .cancelBooking(booking.id!);
                                            if (cancelled) {
                                              snackBarLogger(
                                                context,
                                                'Đã hủy chuyến',
                                                'success',
                                              );
                                            } else {
                                              snackBarLogger(
                                                context,
                                                'Không thể hủy chuyến',
                                                'warning',
                                              );
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.red
                                                .withOpacity(0.9),
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(
                                              color: Colors.red,
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    16,
                                                  ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Hủy chuyến',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Icon(
                                                Icons.close,
                                                size: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // End
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

Widget _infoRow({
  required String icon,
  required String iconColor,
  required String title,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      svgIcon(icon, iconColor),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _statusBadge(String status) {
  Color bgColor;

  switch (status) {
    case 'Đang chờ...':
      bgColor = Colors.orange;
      break;
    case 'Tài xế đang đến':
      bgColor = Colors.blue;
      break;
    case 'Đến đích':
      bgColor = Colors.green;
      break;
    case 'Chuyến xe bị hủy':
      bgColor = Colors.red;
      break;
    case 'Đang trên chuyến xe':
      bgColor = Colors.green;
      break;
    default:
      bgColor = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: TextStyle(
        fontSize: 16,
        color: bgColor,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
