import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/customer/booking_manager.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
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
  State<StatefulWidget> createState() => _TripTracingSate();
}

class _TripTracingSate extends State<TripTracingPage> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  String? _pickupName;
  String? _dropoffName;
  double? _amountDistance;
  bool _cameraMoved = false;
  final logger = Logger();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.read<BookingManager>();
    final authManager = context.read<AuthManager>();
    final userId = authManager.currentUserId;
    final booking = bookingManager.getCurrentTracing(userId: userId);
    final myFunctions = context.watch<MyFunctions>();

    return Scaffold(
      appBar: myAppBar(context, 'Theo dõi cuốc xe'),
      body: Column(
        children: [
          Container(
            height: 400,
            child: FutureBuilder(
              future: booking,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Người anh em chưa đặt xe'));
                }
                final booking = snapshot.data!;
                return FutureBuilder(
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
                    _pickupName = pickup.placeName;
                    _dropoffName = dropoff.placeName;
                    _amountDistance = booking.price;
                    final pickupLat = double.parse(pickup.latitude);
                    final pickupLng = double.parse(pickup.longitude);

                    final dropoffLat = double.parse(dropoff.latitude);
                    final dropoffLng = double.parse(dropoff.longitude);

                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(pickupLat, pickupLng),
                        zoom: 15,
                      ),
                      polylines: _polylines,
                      onMapCreated: (controller) async {
                        if (_cameraMoved) return;
                        _cameraMoved = true;
                        final pickupLatLng = LatLng(pickupLat, pickupLng);
                        final dropoffLatLng = LatLng(dropoffLat, dropoffLng);

                        await _drawRoute(from: pickupLatLng, to: dropoffLatLng);
                        _mapController = controller;
                      },

                      markers: {
                        Marker(
                          markerId: const MarkerId('pickup'),
                          position: LatLng(pickupLat, pickupLng),
                          infoWindow: InfoWindow(
                            title: 'Điểm đón',
                            snippet: pickup.placeName,
                          ),
                        ),
                        Marker(
                          markerId: const MarkerId('dropoff'),
                          position: LatLng(dropoffLat, dropoffLng),
                          infoWindow: InfoWindow(
                            title: 'Điểm đến',
                            snippet: dropoff.placeName,
                          ),
                        ),
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (_dropoffName == null ||
              _pickupName == null ||
              _amountDistance == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
                bottom: 10,
              ),
              child: Column(
                children: [
                  Text(
                    'Thông tin cuốc xe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Điểm đón:',
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pickupName.toString(),
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Điểm đến:',
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dropoffName.toString(),
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Số tiền: ',
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          myFunctions.convertToVND(_amountDistance.toString()),
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
