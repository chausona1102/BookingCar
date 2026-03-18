import 'package:booking_app/models/booking.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/layout/driver/driver_manager.dart';
import 'package:booking_app/ui/shared/avatarCircle.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/showDialogNotif.dart';
import 'package:booking_app/ui/shared/statusChip.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'customer/booking_manager.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<BookingModel>>? _historyFuture;
  late final MyFunctions myFn;
  String? userId;
  String? type;

  @override
  void initState() {
    super.initState();
    myFn = context.read<MyFunctions>();
    _initHistory();
  }

  Future<void> _initHistory() async {
    final user = context.read<AuthManager>().user!;
    final userId = user.id;

    if (user.role == 'customer') {
      setState(() {
        _historyFuture = context
            .read<BookingManager>()
            .fetchHistoryBookingOfUser(userId);
      });
    } else if (user.role == 'driver') {
      final driverId = await context.read<DriverManager>().getDriverIdByUserId(
        userId,
      );

      setState(() {
        _historyFuture = context
            .read<BookingManager>()
            .fetchHistoryBookingOfDriver(driverId);
      });
    }
  }

  String getTypeImage(String type) {
    switch (type) {
      case 'car':
        return 'assets/images/car.png';
      case 'motobike':
        return 'assets/images/motobike.png';
      case 'driver':
        return 'assets/images/driver.png';
      default:
        return 'assets/images/car.png';
    }
  }

  String getTypeText(String type) {
    switch (type) {
      case 'car':
        return 'Ô tô';
      case 'motobike':
        return 'Xe máy';
      case 'driver':
        return 'Tài xế';
      default:
        return 'Ô tô';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Lịch sử'),
      backgroundColor: Colors.green.shade50,
      body: FutureBuilder(
        future: _historyFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(child: Text('Có lỗi xảy ra'));
          }

          final history = snap.data ?? [];
          if (history.isEmpty) {
            return const Center(child: Text('Trống'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final booking = history[index];
              return _buildRow(booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildRow(BookingModel booking) {
    final driver = booking.driver;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () => _showInfo(booking),
        title: Row(
          children: [
            Expanded(
              child: Text(
                booking.bookingDate,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            statusChip(booking.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.user.fullName.isNotEmpty
                      ? booking.user.fullName
                      : booking.user.userName,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.drive_eta_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  driver != null
                      ? (driver.user.fullName.isNotEmpty
                            ? driver.user.fullName
                            : driver.user.userName)
                      : 'Chưa có tài xế',
                  style: TextStyle(
                    fontSize: 13,
                    color: driver != null ? Colors.black87 : Colors.orange,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.pin_drop, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.dropoffLocation.placeName,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          myFn.convertToVND(booking.price.toInt().toString()) + 'đ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  void _showInfo(BookingModel booking) {
    // ignore: no_leading_underscores_for_local_identifiers
    int _selectedStars = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green.shade50,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  const Center(
                    child: Text(
                      'Chi tiết đơn hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date + Status
                  Row(
                    children: [
                      Text(
                        booking.bookingDate,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.fiber_manual_record,
                        size: 5,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        booking.bookingHour,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const Spacer(),
                      statusChip(booking.status),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Trip ID
                  Row(
                    children: [
                      const Text(
                        'Mã chuyến đi  ',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          booking.id ?? '---',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          // Clipboard.setData(ClipboardData(text: booking.id ?? ''));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Driver card
                  if (booking.driver != null) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            avatarCircle(booking.driver!.user, 30),
                            const SizedBox(width: 12),
                            Image.asset(
                              getTypeImage(booking.type),
                              width: 60,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    booking.driver!.licensenumber,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking.driver!.typeCar,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Text(
                            booking.driver!.user.fullName.isNotEmpty
                                ? booking.driver!.user.fullName
                                : booking.driver!.user.userName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const Text(
                            ' 5.0',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Star rating
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(5, (i) {
                              return GestureDetector(
                                onTap: () =>
                                    setModalState(() => _selectedStars = i + 1),
                                child: Icon(
                                  i < _selectedStars
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 36,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const Text('🐤', style: TextStyle(fontSize: 28)),
                              // const SizedBox(width: 8),
                              Text(
                                _selectedStars == 5
                                    ? 'Chuyến đi tuyệt vời'
                                    : _selectedStars >= 3
                                    ? 'Chuyến đi ổn'
                                    : _selectedStars > 0
                                    ? 'Chuyến đi chưa tốt'
                                    : 'Chuyến đi tuyệt vời',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Trip info: distance + dropoff
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking.pickupLocation.placeName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking.dropoffLocation.placeName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Payment info
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue.shade800),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'VISA',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Thanh toán')),
                          Text(
                            '${myFn.convertToVND(booking.price.toInt().toString())}đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          // const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.receipt_long,
                            color: Colors.green,
                          ),
                          title: const Text('Xuất hoá đơn'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Đã phát hành',
                                style: TextStyle(color: Colors.green),
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            showMyDialogNoti(
                              context,
                              "Thông báo",
                              'Tính năng chưa hỗ trợ',
                            );
                          },
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(
                            Icons.headset_mic,
                            color: Colors.grey,
                          ),
                          title: const Text('Hỗ trợ thông tin chuyến'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            showMyDialogNoti(
                              context,
                              "Liên hệ tổng đài",
                              '199 xxx 1000',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            side: const BorderSide(color: Colors.teal),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Xem biên nhận'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: handle re-booking
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Đặt lại'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
