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
import '../../notifications/notification_manager.dart';
import 'package:logger/logger.dart';

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
  late String userId;
  late double? amount;
  double disCount = 1;
  LocationModel? pickupLocation;
  LocationModel? dropoffLocation;
  final logger = Logger();
  @override
  void initState() {
    super.initState();
    type = widget.data?['type'] ?? 'car';
    memberInfo = widget.data?['memberInfo'] as Membership?;
    if (memberInfo != null) {
      disCount = (memberInfo!.discountPercent) / 100;
      logger.i(disCount);
    } else {
      disCount = 1;
    }
    user = widget.data?['user'];
    userId = user!.id;
    _getCurrentLocation();
    _checkTracing(userId);
  }

  Future<void> _checkTracing(String userId) async {
    final bookingManager = context.read<BookingManager>();
    final tracing = await bookingManager.getCurrentTracing(userId: userId);
    if (tracing != null) {
      snackBarLogger(context, 'Bạn đang trong cuốc xe!', 'error');
      context.push('/');
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
    final place = await context.read<BookingManager>().getPlaceName(latLng);
    setState(() {
      _currentLocation = latLng;
      _placeNameSource = place;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.watch<BookingManager>();
    final notisManager = context.watch<NotificationManager>();
    final myFunctions = context.watch<MyFunctions>();

    return Scaffold(
      appBar: myAppBar(context, 'Booking'),
      body: Column(
        children: [
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
                if (memberInfo != null && memberInfo!.discountPercent > 0) {
                  _paymentForDistance = bookingManager
                      .calculatePaymentWithDisCount(
                        _distanceKm,
                        type,
                        disCount,
                      );
                } else {
                  _paymentForDistance = bookingManager.calculatePayment(
                    _distanceKm,
                    type,
                  );
                }
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
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    child: _bookingContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 100,
        color: Colors.white,
        child: Row(
          children: [
            Text(
              'Tổng số tiền:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (memberInfo != null && memberInfo!.discountPercent > 0) ...[
                  Text(
                    _paymentForDistance == null
                        ? '0 vnđ'
                        : '${myFunctions.convertToVND((_paymentForDistance! / (1 - disCount)).toStringAsFixed(0))} vnđ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.red,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
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
              ],
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
                  type: type!,
                );
                if (result) {
                  snackBarLogger(
                    context,
                    'Đặt xe thành công! Chú ý điện thoại dùm rùa nhỏ ạ!',
                    'success',
                  );
                  notisManager.addNotification(
                    'Thông báo từ hệ thống',
                    'success',
                    'Đặt xe thành công',
                    userId,
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
                    if (memberInfo != null && memberInfo!.discountPercent > 0) {
                      _paymentForDistance = context
                          .read<BookingManager>()
                          .calculatePaymentWithDisCount(
                            _distanceKm,
                            type,
                            disCount,
                          );
                    } else {
                      _paymentForDistance = context
                          .read<BookingManager>()
                          .calculatePayment(_distanceKm, type);
                    }
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
                    if (memberInfo != null && memberInfo!.discountPercent > 0) {
                      _paymentForDistance = context
                          .read<BookingManager>()
                          .calculatePaymentWithDisCount(
                            _distanceKm,
                            type,
                            disCount,
                          );
                    } else {
                      _paymentForDistance = context
                          .read<BookingManager>()
                          .calculatePayment(_distanceKm, type);
                    }
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
                    if (memberInfo != null && memberInfo!.discountPercent > 0) {
                      _paymentForDistance = context
                          .read<BookingManager>()
                          .calculatePaymentWithDisCount(
                            _distanceKm,
                            type,
                            disCount,
                          );
                    } else {
                      _paymentForDistance = context
                          .read<BookingManager>()
                          .calculatePayment(_distanceKm, type);
                    }
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
    final myFunctions = context.watch<MyFunctions>();

    if (_destination != null) {
      lat = _destination!.latitude.toStringAsFixed(2);
      lng = _destination!.longitude.toStringAsFixed(2);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: const Text(
            'Thông tin đặt xe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
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
                maxLines: 3,
                overflow: TextOverflow.clip,
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
        if (memberInfo != null &&
            memberInfo!.discountPercent > 0 &&
            !memberInfo!.isExpired) ...[
          Row(
            children: [
              Text(
                'Cấp độ thành viên: ',
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
                  myFunctions.planRevert(memberInfo!.plan),
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
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                'Mức ưu đãi: ',
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
                  '${memberInfo!.discountPercent.toString()}%',
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
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
