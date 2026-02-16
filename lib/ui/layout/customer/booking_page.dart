import 'package:booking_app/models/membership.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:booking_app/ui/shared/iconSvg.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/ui/shared/svgButtonPro.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: myAppBar(context, 'Booking'),
      backgroundColor: Colors.green.shade50,
      body: OrientationBuilder(
        builder: (context, orientation) {
          Widget mapWidget = BookingMap(
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

                if (memberInfo != null &&
                    memberInfo!.discountPercent > 0 &&
                    !memberInfo!.isExpired) {
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
          );

          Widget infoWidget = SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                const SizedBox(height: 5),
                _selecting(),
                const SizedBox(height: 5),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    child: _bookingContent(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );

          if (!isLandscape) {
            return Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: mapWidget,
                ),
                Expanded(child: infoWidget),
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 6, child: mapWidget),
              Expanded(flex: 4, child: infoWidget),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        height: isLandscape ? 50 : 100,
        color: Colors.white,
        child: Row(
          children: [
            Text(
              'Tổng số tiền:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            const SizedBox(width: 10),
            if (isLandscape) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (memberInfo != null &&
                      memberInfo!.discountPercent > 0) ...[
                    Text(
                      _paymentForDistance == null
                          ? '0 vnđ'
                          : '${myFunctions.convertToVND((_paymentForDistance! / (1 - disCount)).toStringAsFixed(0))} vnđ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
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
                ],
              ),
            ],
            if (!isLandscape) ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (memberInfo != null &&
                      memberInfo!.discountPercent > 0) ...[
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
            ],

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _infoRow({
    required String icon,
    required String iconColor,
    required String title,
    required String value,
    required bool notChange,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        svgIcon(icon, iconColor, notChange),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookingContent() {
    final myFunctions = context.watch<MyFunctions>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Center(
        //   child: Text(
        //     'Thông tin đặt xe',
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        //   ),
        // ),
        // const SizedBox(height: 15),
        _infoRow(
          icon: 'assets/icons/location.svg',
          iconColor: 'red',
          title: 'Điểm bắt đầu',
          value: _placeNameSource ?? 'Không xác định',
          notChange: false,
        ),

        const SizedBox(height: 15),

        _infoRow(
          icon: 'assets/icons/location.svg',
          iconColor: 'green',
          title: 'Điểm đến',
          value: _distanceKm == null
              ? _placeNameDest.toString()
              : '${_placeNameDest} (${_distanceKm!.toStringAsFixed(2)} Km)',
          notChange: false,
        ),

        const SizedBox(height: 15),

        /// Membership
        if (memberInfo != null &&
            memberInfo!.discountPercent > 0 &&
            !memberInfo!.isExpired) ...[
          _infoRow(
            icon: 'assets/icons/level.svg',
            iconColor: 'green',
            title: 'Cấp độ thành viên',
            value: myFunctions.planRevert(memberInfo!.plan),
            notChange: true,
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: 'assets/icons/voucher.svg',
            iconColor: 'green',
            title: 'Mức ưu đãi',
            value: '${memberInfo!.discountPercent}%',
            notChange: false,
          ),
        ],
      ],
    );
  }
}
