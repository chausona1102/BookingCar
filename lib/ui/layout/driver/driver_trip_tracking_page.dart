import 'dart:async';

import 'package:booking_app/models/booking.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/auth/customer_manager.dart';
import 'package:booking_app/ui/layout/customer/booking_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:booking_app/ui/shared/iconSvg.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
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

class _DriverTripTrackingPageState extends State<DriverTripTrackingPage> {
  GoogleMapController? _mapController;
  BookingModel? booking;
  StreamSubscription<Position>? _positionStream;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  LatLng? _currentLocation;

  bool _routeDrawn = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final driverManager = context.read<DriverManager>();
      final userId = context.read<AuthManager>().currentUserId;

      final driverId = await driverManager.getDriverIdByUserId(userId!);

      driverManager.listenBookingTracing(driverId);
    });

    _getCurrentLocation();
    _listenToLocation();
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

    if (result.points.isEmpty) return;

    final polyline = Polyline(
      polylineId: PolylineId(id),
      color: color,
      width: 5,
      points: result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(),
    );

    setState(() {
      _polylines.add(polyline);
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
      color: Colors.green,
    );

    _routeDrawn = true;
  }

  void _listenToLocation() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            final latLng = LatLng(position.latitude, position.longitude);

            setState(() {
              _currentLocation = latLng;
              _updateDriverMarker(latLng);
            });

            _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
          },
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
            backgroundColor: Colors.green.shade50,
            appBar: myAppBar(context, 'Theo dõi cuốc xe'),
            body: const Center(
              child: Text(
                'Bạn chưa có chuyến đang chạy',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: myAppBar(context, 'Theo dõi cuốc xe'),
          backgroundColor: Colors.green.shade50,
          body: FutureBuilder(
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

              _pickupLatLng = pickupLatLng;
              _dropoffLatLng = dropoffLatLng;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _setPickupAndDropoffMarkers();
                _drawAllRoutesOnce();
              });

              return isLandscape
                  ? Row(
                      children: [
                        Expanded(flex: 6, child: _buildMap(pickupLatLng)),
                        Expanded(
                          flex: 4,
                          child: _buildTripInfo(
                            booking,
                            pickup.placeName,
                            dropoff.placeName,
                            booking.price,
                            customerManager,
                            bookingManager,
                            myFunctions,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(flex: 6, child: _buildMap(pickupLatLng)),
                        Expanded(
                          flex: 4,
                          child: _buildTripInfo(
                            booking,
                            pickup.placeName,
                            dropoff.placeName,
                            booking.price,
                            customerManager,
                            bookingManager,
                            myFunctions,
                          ),
                        ),
                      ],
                    );
            },
          ),
        );
      },
    );
  }

  Widget _buildMap(LatLng pickupLatLng) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: pickupLatLng, zoom: 16),
      polylines: _polylines,
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  Widget _buildTripInfo(
    BookingModel booking,
    String pickupName,
    String dropoffName,
    double amount,
    CustomerManager customerManager,
    BookingManager bookingManager,
    MyFunctions myFunctions,
  ) { 
    return SingleChildScrollView(
      padding: const EdgeInsets.all(2),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
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
              FutureBuilder<User?>(
                future: customerManager.fetchUserById(booking.userId),
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
                      const SizedBox(height: 12),
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
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng tiền',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${myFunctions.convertToVND(amount.toInt().toString())} đ',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (booking.status == 'accepted') ...[
                    button('Đón khách', 'green', () async {
                      final confirm = await showMyDialog(
                        context,
                        'Xác nhận',
                        'Xác nhận khách đã lên xe',
                        'assets/images/turtle_success.png',
                      );
                      if (confirm != true) return;
                      final isOnTrip = await bookingManager.updateBookingStatus(
                        booking.id!,
                        'ontrip',
                      );
                      if (isOnTrip) {
                        snackBarLogger(context, 'Gét gô', 'success');
                      } else {
                        snackBarLogger(context, 'Lỗi', 'warning');
                      }
                    }),
                  ],
                  if (booking.status == 'ontrip') ...[
                    button('Hoàn thành', 'green', () async {
                      final confirm = await showMyDialog(
                        context,
                        'Xác nhận',
                        'Xác nhận hoàn thành chuyến',
                        'assets/images/turtle_success.png',
                      );
                      if (confirm != true) return;
                      final isCompleted = await bookingManager
                          .updateBookingStatus(booking.id!, 'completed');
                      if (isCompleted) {
                        snackBarLogger(
                          context,
                          'Mang chuyến tiếp theo đến đây',
                          'success',
                        );
                        context.push('/payment-trip-page', extra: booking);
                      } else {
                        snackBarLogger(context, 'Lỗi', 'warning');
                      }
                    }),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
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
