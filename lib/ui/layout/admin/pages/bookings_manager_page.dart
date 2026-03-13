// import 'dart:ffi';

import 'package:booking_app/models/booking.dart';
import 'package:booking_app/ui/layout/admin/manager/booking_admin_manager.dart';
import 'package:booking_app/ui/shared/buildRowInfo.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

class BookingsManagerPage extends StatefulWidget {
  const BookingsManagerPage({super.key});

  @override
  State<BookingsManagerPage> createState() => _BookingsManagerPageState();
}

class _BookingsManagerPageState extends State<BookingsManagerPage> {
  final logger = Logger();
  bool _isLoading = true;
  late final BookingAdminManager bookingManager;
  late final MyFunctions myFn;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Filter
  bool showFilter = false;
  bool sortPrice = false;
  bool sortDate = false;
  String _status = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bookingManager = context.read<BookingAdminManager>();
      myFn = context.read<MyFunctions>();
      try {
        await bookingManager.fetchBookingLimit();
      } catch (e) {
        logger.e('initState error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingAdminManager>().bookings;
    logger.i('-------------');
    logger.i(bookings.length);
    return Scaffold(
      appBar: myAppBar(context, "Quản lý đơn hàng"),
      backgroundColor: Colors.green.shade50,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                _buildSearch(),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator(),
                  ),
                const SizedBox(height: 10),
                _buildFilter(),
                const SizedBox(height: 5),
                _buildLength(bookings.length),
                Expanded(
                  child: bookings.isEmpty
                      ? const Center(
                          child: Text(
                            'Trống',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black38,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) =>
                              _buildRow(bookings[index]),
                        ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    bookingManager.fetchMoreLimit();
                  },
                  child: Text(
                    'Xem thêm',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) async {
          if (value.trim().isEmpty) {
            await bookingManager.fetchBookingLimit();
            return;
          }
          setState(() => _isSearching = true);
          await bookingManager.search(value.trim());
          setState(() => _isSearching = false);
        },
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, username, email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () async {
                    _searchController.clear();
                    await bookingManager.fetchBookingLimit();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
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
                '#${booking.id?.substring(0, 8) ?? '---'}...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _statusChip(booking.status),
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
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.bookingTimeFormatted,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          myFn.convertToVND(booking.price.toString()) + 'đ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final Map<String, (String, Color)> statusMap = {
      'pending': ('Chờ xác nhận', Colors.orange),
      'accepted': ('Đã xác nhận', Colors.blue),
      'ontrip': ('Đang trong chuyến', const Color.fromARGB(255, 33, 243, 243)),
      'completed': ('Hoàn thành', Colors.green),
      'cancelled': ('Đã huỷ', Colors.red),
    };

    final (label, color) = statusMap[status] ?? (status, Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildLength(int length) {
    return Row(
      children: [
        const Spacer(),
        Text('Số dòng $length'),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildFilter() {
    return Row(
      children: [
        const Spacer(),
        if (showFilter) ...[
          TextButton(
            onPressed: () {
              if (sortPrice) {
                bookingManager.sortBookingByPrice('asc');
              } else {
                bookingManager.sortBookingByPrice('desc');
              }
              setState(() {
                sortPrice = !sortPrice;
              });
            },
            child: Row(
              children: [
                Text('Price'),
                Icon(sortPrice ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () {
              if (sortDate) {
                bookingManager.sortBookingByDate('asc');
              } else {
                bookingManager.sortBookingByDate('desc');
              }
              setState(() {
                sortDate = !sortDate;
              });
            },
            child: Row(
              children: [
                Text('Date'),
                Icon(sortDate ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          const SizedBox(width: 10),
          DropdownMenu<String>(
            initialSelection: _status,
            onSelected: (value) {
              setState(() => _status = value!);
              bookingManager.filterByStatus(_status);
            },
            dropdownMenuEntries: [
              'All',
              'completed',
              'pending',
              'accepted',
              'cancelled',
              'ontrip',
            ].map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
          ),
          const SizedBox(width: 10),
        ],
        IconButton(
          onPressed: () {
            setState(() {
              showFilter = !showFilter;
            });
          },
          icon: Icon(Icons.filter_alt_outlined),
          style: IconButton.styleFrom(
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.black),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _showInfo(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green.shade50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Color.fromARGB(255, 243, 112, 103),
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                'Thông tin',
                style: const TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildRowInfo('ID:', booking.id!),
            const SizedBox(height: 10),
            buildRowInfo('Khách hàng:', booking.user.fullName),
            const SizedBox(height: 10),
            buildRowInfo(
              'Tài xế',
              booking.driver?.user.fullName ?? 'Chưa có tài xế',
            ),
            const SizedBox(height: 10),
            buildRowInfo('Điểm đón:', booking.pickupLocation.placeName),
            const SizedBox(height: 10),
            buildRowInfo('Điểm đến:', booking.dropoffLocation.placeName),
            const SizedBox(height: 10),
            buildRowInfo('Ngày đặt:', booking.bookingTimeFormatted),
            const SizedBox(height: 10),
            buildRowInfo(
              'Tổng tiền: ',
              '${myFn.convertToVND(booking.price.toString())}đ',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
