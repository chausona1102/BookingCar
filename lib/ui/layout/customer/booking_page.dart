import 'package:booking_app/models/membership.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/ui/shared/svgButtonPro.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:booking_app/ui/shared/googleMap.dart';
import 'package:provider/provider.dart';
import 'booking_manager.dart';
import 'package:booking_app/models/location.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const BookingPage({super.key, required this.data});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  LatLng? _destination;
  LatLng? _currentLocation;
  String? _placeNameDest = 'Vui lòng chọn địa điểm muốn đến';
  String? _placeNameSource = 'Không tìm thấy địa chỉ của bạn';
  GoogleMapController? _mapController;
  double? _distanceKm;
  double? _paymentForDistance;
  late String? type;
  late Membership? memberInfo;
  late User? user;
  late double? amount;
  LocationModel? pickupLocation;
  LocationModel? dropoffLocation;
  @override
  void initState() {
    super.initState();
    type = widget.data?['type'] ?? 'car';
    memberInfo = widget.data?['memberInfo'] as Membership?;
    user = widget.data?['user'];
    _checkTracing();
    _getCurrentLocation();
  }

  Future<void> _checkTracing() async {
    final bookingManager = context.read<BookingManager>();
    final tracing = await bookingManager.getCurrentTracing(userId: user!.id);

    if (tracing != null) {
      snackBarLogger(context, 'Bạn đang trong cuốc xe!', 'error');
      context.push('/tracing');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('GPS chưa bật');
      return;
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final latLng = LatLng(position.latitude, position.longitude);
    final place = await getPlaceName(latLng);
    setState(() {
      _currentLocation = latLng;
      _placeNameSource = place;
    });
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
    final bookingManager = context.watch<BookingManager>();
    final myFunctions = context.watch<MyFunctions>();
    return Scaffold(
      appBar: myAppBar(context, 'Booking'),
      body: Column(
        children: [
          // _search(),
          // const SizedBox(height: 10),
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
            onDistanceChanged: (km) {
              if (_currentLocation == null || _destination == null) return;
              setState(() {
                _distanceKm = km;
                _paymentForDistance = bookingManager.calculatePayment(
                  _distanceKm,
                  type,
                );
                amount = _paymentForDistance;
                pickupLocation = LocationModel(
                  placeName: _placeNameSource!,
                  latitude: _currentLocation!.latitude.toString(),
                  longitude: _currentLocation!.longitude.toString(),
                );
                dropoffLocation = LocationModel(
                  placeName: _placeNameDest!,
                  latitude: _destination!.latitude.toString(),
                  longitude: _destination!.longitude.toString(),
                );
              });
              if (km < 1) {
                snackBarLogger(
                  context,
                  'Đoạn đường quá ngắn. Khuyến nghị (> 1km)',
                  'error',
                );
              }
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            Text(
              'Tổng số tiền:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            const SizedBox(width: 10),
            Text(
              _paymentForDistance == null
                  ? '0 vnđ'
                  : '${myFunctions.convertToVND(_paymentForDistance!.toStringAsFixed(0))} vnđ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const Spacer(),
            button('Xác nhận', 'success', () async {
              if (_distanceKm == null ||
                  _distanceKm! < 1 ||
                  amount == null ||
                  pickupLocation == null ||
                  dropoffLocation == null) {
                snackBarLogger(context, 'Vui lòng chọn điểm đến', 'warning');
                return;
              }
              if (_distanceKm == null || _distanceKm! < 1) {
                snackBarLogger(
                  context,
                  'Đoạn đường quá ngắn. Quý khách thông cảm giúp rùa nhỏ ạ!',
                  'warning',
                );
              } else {
                final result = await bookingManager.addBooking(
                  userId: user!.id,
                  price: amount!,
                  pickupLocation: pickupLocation!,
                  dropoffLocation: dropoffLocation!,
                );
                if (result) {
                  snackBarLogger(
                    context,
                    'Đặt xe thành công! Chú ý điện thoại dùm rùa nhỏ ạ!',
                    'success',
                  );
                  context.push('/');
                } else {
                  snackBarLogger(
                    context,
                    'Đặt xe không thành công. Vui lòng chọn điểm đến!',
                    'error',
                  );
                }
              }
            }),
          ],
        ),
      ),
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
              type == 'car' ? 'large' : 'medium',
              () {
                setLocal(() {
                  type = 'car';
                });
                setState(() {
                  if (_distanceKm != null) {
                    _paymentForDistance = context
                        .read<BookingManager>()
                        .calculatePayment(_distanceKm, type);
                  }
                });
              },
            ),
            const SizedBox(width: 10),
            svgButtonPro(
              'assets/icons/motobike.svg',
              'Xe máy',
              'dart45',
              type == 'motobike',
              type == 'motobike' ? 'large' : 'medium',
              () {
                setLocal(() {
                  type = 'motobike';
                });
                setState(() {
                  if (_distanceKm != null) {
                    _paymentForDistance = context
                        .read<BookingManager>()
                        .calculatePayment(_distanceKm, type);
                  }
                });
              },
            ),
            const SizedBox(width: 10),
            svgButtonPro(
              'assets/icons/driver.svg',
              'Tài xế',
              'dart45',
              type == 'driver',
              type == 'driver' ? 'large' : 'medium',
              () {
                setLocal(() {
                  type = 'driver';
                });
                snackBarLogger(
                  context,
                  'Tài xế sẽ đến chậm đôi chút, quý khách thông cảm giúp rùa nhỏ ạ!',
                  'success',
                );
                setState(() {
                  if (_distanceKm != null) {
                    _paymentForDistance = context
                        .read<BookingManager>()
                        .calculatePayment(_distanceKm, type);
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _bookingContent() {
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
                _distanceKm == null
                    ? _placeNameDest.toString()
                    : '${_placeNameDest} (${_distanceKm!.toStringAsFixed(2)}Km)',
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

  // Widget _bookingMotoBike() {
  //   return Center(child: Text('Dat xe may'));
  // }

  // Widget _bookingDriver() {
  //   return Center(child: Text('Dat tai xe'));
  // }

  Widget _urlNotFound() {
    return Center();
  }
}
