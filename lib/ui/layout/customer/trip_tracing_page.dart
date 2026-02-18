import 'package:booking_app/models/driver.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/customer/booking_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/iconSvg.dart';
import 'package:booking_app/ui/shared/myAppBarPro.dart';
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

class _TripTracingState extends State<TripTracingPage>
    with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  bool _cameraMoved = false;
  final logger = Logger();

  late AnimationController _sheetAnimController;
  late Animation<Offset> _sheetSlide;
  bool _sheetVisible = false;

  @override
  void initState() {
    super.initState();

    _sheetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _sheetAnimController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthManager>();
      final bookingManager = context.read<BookingManager>();
      final userId = auth.currentUserId;
      if (userId != null) {
        bookingManager.listenCurrentBooking(userId);
      }
    });
  }

  @override
  void dispose() {
    _sheetAnimController.dispose();
    super.dispose();
  }

  void _toggleSheet() {
    if (_sheetVisible) {
      _sheetAnimController.reverse();
    } else {
      _sheetAnimController.forward();
    }
    setState(() => _sheetVisible = !_sheetVisible);
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
          color: const Color(0xFF00C853),
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

  Widget _buildToggleButton(bool isLandscape) {
    return Positioned(
      bottom: isLandscape ? 10 : 40,
      left: 0,
      right: isLandscape ? MediaQuery.of(context).size.width * .6 : 0,
      child: Center(
        child: GestureDetector(
          onTap: _toggleSheet,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: _sheetVisible ? Colors.black87 : const Color(0xFF00C853),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLandscape) ...[
                  Icon(
                    _sheetVisible
                        ? Icons.keyboard_arrow_down
                        : Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ] else ...[
                  Icon(
                    _sheetVisible
                        ? Icons.keyboard_arrow_down
                        : Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _sheetVisible ? 'Đóng thông tin' : 'Xem thông tin chuyến',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingManager>().currentBooking;
    final bookingManager = context.read<BookingManager>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: myAppBarPro(context, 'Theo dõi cuốc xe'),
      body: booking == null
          ? _buildEmptyState()
          : FutureBuilder(
              key: ValueKey('${booking.id}_${booking.status}'),
              future: Future.wait([
                bookingManager.getLocationById(id: booking.pickupLocationId),
                bookingManager.getLocationById(id: booking.dropoffLocationId),
              ]),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pickup = snap.data![0]!;
                final dropoff = snap.data![1]!;

                final pickupLatLng = LatLng(
                  double.parse(pickup.latitude),
                  double.parse(pickup.longitude),
                );
                final dropoffLatLng = LatLng(
                  double.parse(dropoff.latitude),
                  double.parse(dropoff.longitude),
                );

                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: pickupLatLng,
                        zoom: 16,
                      ),
                      polylines: _polylines,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) async {
                        if (_cameraMoved) return;
                        _cameraMoved = true;
                        mapController = controller;
                        await _drawRoute(from: pickupLatLng, to: dropoffLatLng);
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('pickup'),
                          position: pickupLatLng,
                        ),
                        Marker(
                          markerId: const MarkerId('dropoff'),
                          position: dropoffLatLng,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                        ),
                      },
                    ),

                    Positioned(
                      bottom: isLandscape ? 10 : 120,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _statusBadge(_mapStatus(booking.status)),
                      ),
                    ),

                    SlideTransition(
                      position: _sheetSlide,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildBottomSheet(
                          context,
                          pickup,
                          dropoff,
                          booking,
                          bookingManager,
                        ),
                      ),
                    ),

                    _buildToggleButton(isLandscape),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/turtle_warning.png', height: 120),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa đặt xe',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    dynamic pickup,
    dynamic dropoff,
    dynamic booking,
    BookingManager bookingManager,
  ) {
    final driverManager = context.read<DriverManager>();
    final myFunctions = context.watch<MyFunctions>();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    icon: 'assets/icons/location.svg',
                    iconColor: 'red',
                    title: 'Điểm đón',
                    value: pickup.placeName,
                  ),
                  const SizedBox(height: 14),
                  _infoRow(
                    icon: 'assets/icons/location.svg',
                    iconColor: 'green',
                    title: 'Điểm đến',
                    value: dropoff.placeName,
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<Driver?>(
                    future: driverManager.fetchDriverById(id: booking.driverId),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return _infoRow(
                          icon: 'assets/icons/driver.svg',
                          iconColor: 'black',
                          title: 'Tài xế',
                          value: 'Đang tải...',
                        );
                      }
                      if (!snap.hasData || snap.data == null) {
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
                          const SizedBox(height: 14),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '${myFunctions.convertToVND(booking.price.toInt().toString())} ₫',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00C853),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        final confirm = await showMyDialog(
                          context,
                          'Hủy chuyến',
                          'Xác nhận chắc chắn hủy chuyến',
                          'assets/images/turtle_warning.png',
                        );
                        if (confirm != true) return;
                        final cancelled = await bookingManager
                            .updateBookingStatus(booking.id!, 'cancelled');
                        if (cancelled) {
                          snackBarLogger(context, 'Đã hủy chuyến', 'success');
                        } else {
                          snackBarLogger(
                            context,
                            'Không thể hủy chuyến',
                            'warning',
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Hủy chuyến',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      svgIcon(icon, iconColor, false),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _statusBadge(String status) {
  Color bgColor;
  IconData icon;

  switch (status) {
    case 'Đang chờ...':
      bgColor = Colors.orange;
      icon = Icons.access_time_rounded;
      break;
    case 'Tài xế đang đến':
      bgColor = Colors.blue;
      icon = Icons.directions_car_rounded;
      break;
    case 'Đến đích':
      bgColor = const Color(0xFF00C853);
      icon = Icons.check_circle_outline_rounded;
      break;
    case 'Chuyến xe bị hủy':
      bgColor = Colors.red;
      icon = Icons.cancel_outlined;
      break;
    case 'Đang trên chuyến xe':
      bgColor = const Color(0xFF00C853);
      icon = Icons.navigation_rounded;
      break;
    default:
      bgColor = Colors.grey;
      icon = Icons.help_outline_rounded;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: bgColor.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: bgColor, size: 18),
        const SizedBox(width: 8),
        Text(
          status,
          style: TextStyle(
            fontSize: 14,
            color: bgColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
