import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BookingMap extends StatefulWidget {
  final Function(LatLng, String) onSelect;
  final Function(GoogleMapController)? onMapCreated;
  final Function(double)? onDistanceChanged;

  const BookingMap({
    super.key,
    required this.onSelect,
    this.onMapCreated,
    this.onDistanceChanged,
  });

  @override
  State<BookingMap> createState() => _BookingMapState();
}

class _BookingMapState extends State<BookingMap> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  LatLng? _destination;
  // double? _distanceKm;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  double _calculatePolylineDistance(List<PointLatLng> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  Future<void> _drawRoute() async {
    if (_currentLocation == null || _destination == null) return;
    final API_KEY = dotenv.env['API_KEY'];
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: API_KEY.toString(),
      request: PolylineRequest(
        origin: PointLatLng(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        ),
        destination: PointLatLng(
          _destination!.latitude,
          _destination!.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isEmpty) return;

    final meter = _calculatePolylineDistance(result.points);
    final km = meter / 1000;
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
      // _distanceKm = km;
    });
    widget.onDistanceChanged?.call(km);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('GPS chưa bật');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Người dùng từ chối quyền');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Quyền bị từ chối vĩnh viễn');
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
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(10.762622, 106.660172),
          zoom: 14,
        ),
        polylines: _polylines,
        myLocationEnabled: true,
        onMapCreated: (controller) => _mapController = controller,
        onTap: (pos) async {
          final name = await placemarkFromCoordinates(
            pos.latitude,
            pos.longitude,
          );

          setState(() => _destination = pos);

          widget.onSelect(pos, name.first.street ?? '');

          await _drawRoute();
        },
        markers: {
          if (_currentLocation != null)
            Marker(
              markerId: const MarkerId('current'),
              position: _currentLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          if (_destination != null)
            Marker(
              markerId: const MarkerId('dest'),
              position: _destination!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
        },
      ),
    );
  }
}
