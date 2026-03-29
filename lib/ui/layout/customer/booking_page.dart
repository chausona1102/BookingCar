import 'package:booking_app/models/driver.dart';
import 'package:booking_app/models/membership.dart';
import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/shared/backPositioned.dart';
import 'package:booking_app/ui/shared/iconSvg.dart';
import 'package:booking_app/ui/shared/myAppBarPro.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/ui/shared/svgButtonPro.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  LatLng? _destination;
  LatLng? _currentLocation;
  String? _placeNameDest = 'Vui lòng chọn địa điểm muốn đến';
  String? _placeNameSource = 'Không tìm thấy địa chỉ của bạn';
  GoogleMapController? mapController;
  double? _distanceKm;
  double? _paymentForDistance;
  late String? type;
  late Membership? memberInfo;
  late User? user;
  late Driver? driver;
  late String userId;
  late double? amount;
  double disCount = 1;
  LocationModel? pickupLocation;
  LocationModel? dropoffLocation;
  final logger = Logger();
  bool _isLoading = false;
  late AnimationController _sheetAnimController;
  late Animation<Offset> _sheetSlide;
  bool _sheetVisible = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
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

    type = widget.data?['type'] ?? 'car';
    memberInfo = widget.data?['memberInfo'] as Membership?;
    driver = widget.data?['driver'] as Driver?;
    logger.i(driver);
    if (memberInfo != null) {
      disCount = (memberInfo!.discountPercent) / 100;
    } else {
      disCount = 1;
    }
    user = widget.data?['user'];
    userId = user!.id;
    _getCurrentLocation();
    _checkTracing(userId);
    setState(() {
      _isLoading = false;
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
    if (!serviceEnabled) return;
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

  void _recalcPayment() {
    if (_distanceKm == null) return;
    setState(() {
      if (memberInfo != null &&
          memberInfo!.discountPercent > 0 &&
          !memberInfo!.isExpired) {
        _paymentForDistance = context
            .read<BookingManager>()
            .calculatePaymentWithDisCount(_distanceKm, type, disCount);
      } else {
        _paymentForDistance = context.read<BookingManager>().calculatePayment(
          _distanceKm,
          type,
        );
      }
      amount = _paymentForDistance;
    });
  }

  Widget _buildToggleButton(bool isLandscape) {
    return Positioned(
      bottom: isLandscape ? 10 : 40,
      left: isLandscape ? MediaQuery.of(context).size.width * .7 : 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _toggleSheet,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: _sheetVisible ? Colors.black87 : Colors.green.shade500,
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
                    _sheetVisible ? 'Đóng thông tin' : 'Xem thông tin đặt xe',
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

  Widget _buildPriceBadge(MyFunctions myFunctions, bool isLandscape) {
    if (_paymentForDistance == null) return const SizedBox.shrink();
    return Positioned(
      bottom: isLandscape ? 15 : 120,
      left: 0,
      right: isLandscape ? MediaQuery.of(context).size.width * 0.4 : 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.payments_outlined,
                color: Color(0xFF00C853),
                size: 18,
              ),
              const SizedBox(width: 8),
              if (memberInfo != null &&
                  memberInfo!.discountPercent > 0 &&
                  !memberInfo!.isExpired) ...[
                Text(
                  '${myFunctions.convertToVND((_paymentForDistance! / (1 - disCount)).toStringAsFixed(0))} ₫',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '${myFunctions.convertToVND(_paymentForDistance!.toStringAsFixed(0))} ₫',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00C853),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(
    MyFunctions myFunctions,
    BookingManager bookingManager,
    NotificationManager notisManager,
    bool isLandscape,
  ) {
    return Container(
      margin: isLandscape
          ? EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * .5,
              40,
              12,
              50,
            )
          : const EdgeInsets.fromLTRB(12, 0, 12, 100),
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
      child: SingleChildScrollView(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  selecting(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1),
                  ),

                  _infoRow(
                    icon: 'assets/icons/location.svg',
                    iconColor: 'red',
                    title: 'Điểm bắt đầu',
                    value: _placeNameSource ?? 'Không xác định',
                    notChange: false,
                  ),
                  const SizedBox(height: 14),

                  _infoRow(
                    icon: 'assets/icons/location.svg',
                    iconColor: 'green',
                    title: 'Điểm đến',
                    value: _distanceKm == null
                        ? _placeNameDest.toString()
                        : '$_placeNameDest (${_distanceKm!.toStringAsFixed(2)} km)',
                    notChange: false,
                  ),

                  if (memberInfo != null &&
                      memberInfo!.discountPercent > 0 &&
                      !memberInfo!.isExpired) ...[
                    const SizedBox(height: 14),
                    _infoRow(
                      icon: 'assets/icons/level.svg',
                      iconColor: 'green',
                      title: 'Cấp độ thành viên',
                      value: myFunctions.planRevert(memberInfo!.plan),
                      notChange: true,
                    ),
                    const SizedBox(height: 14),
                    _infoRow(
                      icon: 'assets/icons/voucher.svg',
                      iconColor: 'green',
                      title: 'Mức ưu đãi',
                      value: '${memberInfo!.discountPercent}%',
                      notChange: false,
                    ),
                  ],
                  if (driver != null && type == 'driver') ...[
                    const SizedBox(height: 14),
                    _infoRow(
                      icon: 'assets/icons/driver.svg',
                      iconColor: 'green',
                      title: 'Tài xế',
                      value: driver!.user.fullName,
                      notChange: false,
                    ),
                    const SizedBox(height: 14),
                    _infoRow(
                      icon: 'assets/icons/car.svg',
                      iconColor: 'green',
                      title: 'Biển số',
                      value: driver!.carnumber,
                      notChange: false,
                    ),
                  ],

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
                      if (_paymentForDistance != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (memberInfo != null &&
                                memberInfo!.discountPercent > 0 &&
                                !memberInfo!.isExpired)
                              Text(
                                '${myFunctions.convertToVND((_paymentForDistance! / (1 - disCount)).toStringAsFixed(0))} ₫',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '${myFunctions.convertToVND(_paymentForDistance!.toStringAsFixed(0))} ₫',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00C853),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        const Text(
                          '—',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Xác nhận đặt xe
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_distanceKm == null ||
                            amount == null ||
                            pickupLocation == null ||
                            dropoffLocation == null) {
                          snackBarLogger(
                            context,
                            'Vui lòng chọn điểm đến',
                            'warning',
                          );
                          return;
                        }
                        if (_distanceKm! < 0.5) {
                          snackBarLogger(
                            context,
                            'Đoạn đường quá ngắn. Quý khách thông cảm giúp rùa nhỏ ạ!',
                            'warning',
                          );
                          return;
                        }
                        bool result = false;
                        if (type == 'driver') {
                          result = await bookingManager.addBookingWithDriver(
                            userId: user!.id,
                            price: amount!,
                            pickupLocation: pickupLocation!,
                            dropoffLocation: dropoffLocation!,
                            driverId: driver!.id,
                            type: type!,
                          );
                        } else {
                          result = await bookingManager.addBooking(
                            userId: user!.id,
                            price: amount!,
                            pickupLocation: pickupLocation!,
                            dropoffLocation: dropoffLocation!,
                            type: type!,
                          );
                        }
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Xác nhận đặt xe',
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.watch<BookingManager>();
    final notisManager = context.watch<NotificationManager>();
    final myFunctions = context.watch<MyFunctions>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: myAppBarPro(context, 'Booking'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(),
              SpinKitCircle(color: Colors.green, size: 50.0),
              const SizedBox(height: 10),
              const Text('Đang tải...'),
              Spacer(),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: isLandscape ? null : myAppBarPro(context, 'Booking'),
        body: Stack(
          children: [
            BookingMap(
              onMapCreated: (controller) {
                mapController = controller;
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
                });
                _recalcPayment();

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
              },
            ),

            _buildPriceBadge(myFunctions, isLandscape),

            SlideTransition(
              position: _sheetSlide,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomSheet(
                  myFunctions,
                  bookingManager,
                  notisManager,
                  isLandscape,
                ),
              ),
            ),

            _buildToggleButton(isLandscape),

            if (isLandscape) ...[backPositioned(context)],
          ],
        ),
      );
    }
  }

  Widget selecting() {
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
              type == 'car' ? 'medium' : 'small',
              () {
                // setLocal(() => type = 'car');
                setState(() {
                  type = 'car';
                });
                _recalcPayment();
              },
            ),
            const SizedBox(width: 10),
            svgButtonPro(
              'assets/icons/motobike.svg',
              'Xe máy',
              'dart45',
              type == 'motobike',
              type == 'motobike' ? 'medium' : 'small',
              () {
                setState(() => type = 'motobike');
                _recalcPayment();
              },
            ),
            if (driver != null) ...[
              const SizedBox(width: 10),
              svgButtonPro(
                'assets/icons/driver.svg',
                'Tài xế',
                'dart45',
                type == 'driver',
                type == 'driver' ? 'medium' : 'small',
                () {
                  setState(() => type = 'driver');
                  snackBarLogger(
                    context,
                    'Tài xế sẽ đến chậm đôi chút, quý khách thông cảm giúp rùa nhỏ ạ!',
                    'success',
                  );
                  _recalcPayment();
                },
              ),
            ],
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
}
