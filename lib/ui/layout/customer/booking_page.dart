import 'package:booking_app/models/membership.dart';
import 'package:booking_app/ui/shared/myappbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const BookingPage({super.key, required this.data});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  LatLng? _currentLocation;
  GoogleMapController? _mapController;
  late String? type;
  late Membership? memberInfo;
  @override
  void initState() {
    super.initState();
    final data = widget.data;
    type = data?['type'] as String?;
    memberInfo = data?['memberInfo'] as Membership?;
    print(type);
    print(memberInfo);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('GPS chưa bật');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Từ chối quyền vị trí');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Từ chối vĩnh viễn');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'car':
        return _bookingCar();
      case 'motobike':
        return _bookingMotoBike();
      case 'driver':
        return _bookingDriver();
      default:
        return _urlNotFound();
    }
  }

  Widget _bookingCar() {
    return Scaffold(
      appBar: myAppBar(context, 'Booking'),
      body: Column(
        children: [
          Container(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(10.762622, 106.660172),
                zoom: 14,
              ),
              myLocationEnabled: true, // 🔵 chấm xanh
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
                _getCurrentLocation(); // lấy vị trí khi map load
              },
              onTap: (LatLng position) {
                print('Selected: $position');
              },
              markers: _currentLocation == null
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('current'),
                        position: _currentLocation!,
                      ),
                    },
            ),
          ),
          Row(
            children: [
              Text(
                'Điểm đến:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'vị trí hiện tại',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bookingMotoBike() {
    return Scaffold(
      appBar: myAppBar(context, 'Booking'),
      body: Center(child: Text('Dat xe may')),
    );
  }

  Widget _bookingDriver() {
    return Scaffold(
      appBar: myAppBar(context, 'Booking'),
      body: Center(child: Text('Dat tai xe')),
    );
  }

  Widget _urlNotFound() {
    return Scaffold();
  }
}
