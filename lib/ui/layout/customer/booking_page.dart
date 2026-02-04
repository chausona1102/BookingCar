import 'package:booking_app/models/membership.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/shared/myappbar.dart';
import 'package:booking_app/ui/shared/svgbuttonpro.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:booking_app/ui/shared/googleMap.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const BookingPage({super.key, required this.data});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  LatLng? _destination;
  String? _placeNameDest = 'Vui lòng chọn địa điểm muốn đến';
  GoogleMapController? _mapController;
  late String? type;
  late Membership? memberInfo;
  late User? user;
  @override
  void initState() {
    super.initState();
    type = widget.data?['type'] ?? 'car';
    memberInfo = widget.data?['memberInfo'] as Membership?;
    user = widget.data?['user'];
  }

  Future<LatLng?> searchAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return LatLng(loc.latitude, loc.longitude);
      }
    } catch (e) {}
    return null;
  }

  Future<String> getPlaceName(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) {
        return '(${latLng.latitude.toStringAsFixed(4)}, '
            '${latLng.longitude.toStringAsFixed(4)})';
      }

      final p = placemarks.first;

      final parts = [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((e) => e != null && e!.isNotEmpty).toList();

      if (parts.isEmpty) {
        return '(${latLng.latitude.toStringAsFixed(4)}, '
            '${latLng.longitude.toStringAsFixed(4)})';
      }

      return parts.join(', ');
    } catch (e) {
      return '(${latLng.latitude.toStringAsFixed(4)}, '
          '${latLng.longitude.toStringAsFixed(4)})';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Booking'),
      body: Column(
        children: [
          _search(),
          const SizedBox(height: 10),
          BookingMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onSelect: (latLng, place) {
              setState(() {
                _destination = latLng;
                _placeNameDest = place;
              });
            },
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              children: [
                _selecting(),
                const SizedBox(height: 10),
                _bookingContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingContent() {
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

  Widget _search() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Nhập điểm đến',
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: (value) async {
        final latLng = await searchAddress(value);
        if (latLng != null) {
          setState(() {
            _destination = latLng;
          });

          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
        }
      },
    );
  }

  Widget _selecting() {
    return StatefulBuilder(
      builder: (context, setLocal) {
        return Row(
          children: [
            svgButtonPro(
              'assets/icons/car.svg',
              'Ô tô',
              'dart45',
              type == 'car',
              () {
                setLocal(() {
                  type = 'car';
                });
                setState(() {});
              },
            ),
            const SizedBox(width: 10),
            svgButtonPro(
              'assets/icons/motobike.svg',
              'Xe máy',
              'dart45',
              type == 'motobike',
              () {
                setLocal(() {
                  type = 'motobike';
                });
                setState(() {});
              },
            ),
            const SizedBox(width: 10),
            svgButtonPro(
              'assets/icons/driver.svg',
              'Tài xế',
              'dart45',
              type == 'driver',
              () {
                setLocal(() {
                  type = 'driver';
                });
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Widget _bookingCar() {
    String lat = '--';
    String lng = '--';

    if (_destination != null) {
      lat = _destination!.latitude.toStringAsFixed(2);
      lng = _destination!.longitude.toStringAsFixed(2);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Điểm bắt đầu:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Vị trí hiện tại',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
                fontWeight: FontWeight.w700,
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
                _placeNameDest.toString(),
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
      ],
    );
  }

  Widget _bookingMotoBike() {
    return Center(child: Text('Dat xe may'));
  }

  Widget _bookingDriver() {
    return Center(child: Text('Dat tai xe'));
  }

  Widget _urlNotFound() {
    return Center();
  }
}
