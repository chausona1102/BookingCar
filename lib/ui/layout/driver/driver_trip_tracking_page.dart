import 'dart:async';
import 'package:booking_app/models/booking.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/auth/customer_manager.dart';
import 'package:booking_app/ui/layout/customer/booking_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/iconSvg.dart';
import 'package:booking_app/ui/shared/myAppBarPro.dart';
import 'package:booking_app/ui/shared/showDialog.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DriverTripTrackingPage extends StatefulWidget {
  const DriverTripTrackingPage({super.key});

  @override
  State<DriverTripTrackingPage> createState() => _DriverTripTrackingPageState();
}

class _DriverTripTrackingPageState extends State<DriverTripTrackingPage>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  LatLng? _currentLocation;

  bool _routeDrawn = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final driverManager = context.read<DriverManager>();
      final userId = context.read<AuthManager>().currentUserId;
      final driverId = await driverManager.getDriverIdByUserId(userId!);
      driverManager.listenBookingTracing(driverId);
    });

    _getCurrentLocation();
    _listenToLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
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

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentLocation = latLng;
      _updateDriverMarker(latLng);
    });
    _drawAllRoutesOnce();
  }

  void _updateDriverMarker(LatLng latLng) {
    _markers.removeWhere((m) => m.markerId.value == 'driver');
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  Future<void> _drawRoute({
    required LatLng from,
    required LatLng to,
    required String id,
    required Color color,
  }) async {
    final apiKey = dotenv.env['API_KEY']!;
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.driving,
      ),
    );
    print('DEBUG loc: $_currentLocation');
    print('DEBUG pickup: $_pickupLatLng');
    print('DEBUG dropoff: $_dropoffLatLng');
    if (result.points.isEmpty) return;
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(id),
          color: color,
          width: 5,
          points: result.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
        ),
      );
    });
  }

  void _setPickupAndDropoffMarkers() {
    if (_pickupLatLng == null || _dropoffLatLng == null) return;
    _markers.removeWhere(
      (m) => m.markerId.value == 'pickup' || m.markerId.value == 'dropoff',
    );
    _markers.addAll({
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Điểm đón'),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: _dropoffLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Điểm đến'),
      ),
    });
  }

  Future<void> _drawAllRoutesOnce() async {
    if (_routeDrawn) return;
    if (_currentLocation == null ||
        _pickupLatLng == null ||
        _dropoffLatLng == null)
      return;
    await _drawRoute(
      from: _currentLocation!,
      to: _pickupLatLng!,
      id: 'toPickup',
      color: Colors.orange,
    );
    await _drawRoute(
      from: _pickupLatLng!,
      to: _dropoffLatLng!,
      id: 'toDropoff',
      color: const Color(0xFF00C853),
    );
    _routeDrawn = true;
  }

  void _listenToLocation() {
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          final latLng = LatLng(position.latitude, position.longitude);
          setState(() {
            _currentLocation = latLng;
            _updateDriverMarker(latLng);
          });
          _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
        });
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'accepted':
        return 'Đang đến điểm đón';
      case 'ontrip':
        return 'Đang trên chuyến xe';
      case 'completed':
        return 'Chuyến đã hoàn thành';
      case 'cancelled':
        return 'Chuyến bị hủy';
      default:
        return 'Đang xử lý...';
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

  Widget _buildBottomSheet(
    BuildContext context,
    BookingModel booking,
    String pickupName,
    String dropoffName,
    CustomerManager customerManager,
    BookingManager bookingManager,
    MyFunctions myFunctions,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 100),
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.62,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    icon: 'assets/icons/location.svg',
                    iconColor: 'red',
                    title: 'Điểm đón',
                    value: pickupName,
                  ),
                  const SizedBox(height: 14),
                  _infoRow(
                    icon: 'assets/icons/location.svg',
                    iconColor: 'green',
                    title: 'Điểm đến',
                    value: dropoffName,
                  ),
                  const SizedBox(height: 14),

                  FutureBuilder<User?>(
                    future: customerManager.fetchUserById(booking.user.id),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return _infoRow(
                          icon: 'assets/icons/user.svg',
                          iconColor: 'black',
                          title: 'Khách hàng',
                          value: 'Đang tải...',
                        );
                      }
                      final user = snap.data!;
                      return Column(
                        children: [
                          _infoRow(
                            icon: 'assets/icons/user.svg',
                            iconColor: 'black',
                            title: 'Khách hàng',
                            value: user.fullName,
                          ),
                          const SizedBox(height: 14),
                          _infoRow(
                            icon: 'assets/icons/phone.svg',
                            iconColor: 'black',
                            title: 'Số điện thoại',
                            value: user.phoneNumber,
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

                  if (booking.status == 'accepted')
                    _actionButton(
                      label: 'Đón khách',
                      icon: Icons.directions_car_rounded,
                      color: Colors.blue,
                      onTap: () async {
                        final confirm = await showMyDialog(
                          context,
                          'Xác nhận',
                          'Xác nhận khách đã lên xe',
                          'assets/images/turtle_success.png',
                        );
                        if (confirm != true) return;
                        final ok = await bookingManager.updateBookingStatus(
                          booking.id!,
                          'ontrip',
                        );
                        snackBarLogger(
                          context,
                          ok ? 'Gét gô' : 'Lỗi',
                          ok ? 'success' : 'warning',
                        );
                      },
                    ),

                  if (booking.status == 'ontrip')
                    _actionButton(
                      label: 'Hoàn thành chuyến',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF00C853),
                      onTap: () async {
                        final confirm = await showMyDialog(
                          context,
                          'Xác nhận',
                          'Xác nhận hoàn thành chuyến',
                          'assets/images/turtle_success.png',
                        );
                        if (confirm != true) return;
                        final ok = await bookingManager.updateBookingStatus(
                          booking.id!,
                          'completed',
                        );
                        if (ok) {
                          snackBarLogger(
                            context,
                            'Mang chuyến tiếp theo đến đây',
                            'success',
                          );
                          context.push('/payment-trip-page', extra: booking);
                        } else {
                          snackBarLogger(context, 'Lỗi', 'warning');
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.read<BookingManager>();
    final customerManager = context.read<CustomerManager>();
    final myFunctions = context.watch<MyFunctions>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Consumer<DriverManager>(
      builder: (context, driverManager, child) {
        final booking = driverManager.currentBooking;

        if (booking == null) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: myAppBarPro(context, 'Theo dõi cuốc xe'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có chuyến đang chạy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: myAppBarPro(context, 'Theo dõi cuốc xe'),
          body: FutureBuilder(
            future: Future.wait([
              Future.value(booking.pickupLocation),
              Future.value(booking.dropoffLocation),
            ]),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final pickup = snap.data![0];
              final dropoff = snap.data![1];

              final pickupLatLng = LatLng(
                double.parse(pickup.latitude),
                double.parse(pickup.longitude),
              );
              final dropoffLatLng = LatLng(
                double.parse(dropoff.latitude),
                double.parse(dropoff.longitude),
              );

              _pickupLatLng = pickupLatLng;
              _dropoffLatLng = dropoffLatLng;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _setPickupAndDropoffMarkers();
                _drawAllRoutesOnce();
              });

              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: pickupLatLng,
                      zoom: 16,
                    ),
                    polylines: _polylines,
                    markers: _markers,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) => _mapController = controller,
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
                        booking,
                        pickup.placeName,
                        dropoff.placeName,
                        customerManager,
                        bookingManager,
                        myFunctions,
                      ),
                    ),
                  ),

                  _buildToggleButton(isLandscape),
                ],
              );
            },
          ),
        );
      },
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

Widget _actionButton({
  required String label,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

Widget _statusBadge(String status) {
  Color bgColor;
  IconData icon;

  switch (status) {
    case 'Đang đến điểm đón':
      bgColor = Colors.orange;
      icon = Icons.navigation_rounded;
      break;
    case 'Đang trên chuyến xe':
      bgColor = const Color(0xFF00C853);
      icon = Icons.directions_car_rounded;
      break;
    case 'Chuyến đã hoàn thành':
      bgColor = Colors.blue;
      icon = Icons.check_circle_outline_rounded;
      break;
    case 'Chuyến bị hủy':
      bgColor = Colors.red;
      icon = Icons.cancel_outlined;
      break;
    default:
      bgColor = Colors.grey;
      icon = Icons.access_time_rounded;
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
