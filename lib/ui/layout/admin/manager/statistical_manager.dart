import 'package:booking_app/models/booking.dart';
import 'package:booking_app/services/admin/statistical_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class StatisticalManager extends ChangeNotifier {
  final logger = Logger();
  final StatisticalService _statisticalService = StatisticalService();
  List<BookingModel> bookings = [];

  Future<void> fetchAllBookings() async {
    bookings = (await _statisticalService.fetchAllBookings())!;
    notifyListeners();
  }

  // ───────────────────────────── DOANH THU ─────────────────────────────

  /// Tổng doanh thu
  double get totalRevenue => bookings
      .where((b) => b.status == 'completed')
      .fold(0, (sum, b) => sum + b.price);

  /// Doanh thu theo ngày  { '2026-02-09': 28305.0, ... }
  Map<String, double> get revenueByDate {
    final Map<String, double> map = {};
    for (final b in bookings.where((b) => b.status == 'completed')) {
      final key = b.bookingTime.toLocal().toString().substring(0, 10);
      map[key] = (map[key] ?? 0) + b.price;
    }
    return map;
  }

  /// Doanh thu theo tháng  { '2026-02': 28305.0, ... }
  Map<String, double> get revenueByMonth {
    final Map<String, double> map = {};
    for (final b in bookings.where((b) => b.status == 'completed')) {
      final key = b.bookingTime.toLocal().toString().substring(0, 7);
      map[key] = (map[key] ?? 0) + b.price;
    }
    return map;
  }

  // ───────────────────────────── ĐƠN HÀNG ─────────────────────────────

  /// Tổng số đơn
  int get totalBookings => bookings.length;

  /// Đếm theo status
  Map<String, int> get bookingsByStatus {
    final Map<String, int> map = {};
    for (final b in bookings) {
      map[b.status] = (map[b.status] ?? 0) + 1;
    }
    return map;
  }

  int get pendingCount => bookingsByStatus['pending'] ?? 0;
  int get acceptedCount => bookingsByStatus['accepted'] ?? 0;
  int get ontripCount => bookingsByStatus['ontrip'] ?? 0;
  int get completedCount => bookingsByStatus['completed'] ?? 0;
  int get cancelledCount => bookingsByStatus['cancelled'] ?? 0;

  double get completionRate =>
      totalBookings == 0 ? 0 : (completedCount / totalBookings) * 100;

  double get cancellationRate =>
      totalBookings == 0 ? 0 : (cancelledCount / totalBookings) * 100;

  Map<String, int> get bookingsByType {
    final Map<String, int> map = {};
    for (final b in bookings) {
      map[b.type] = (map[b.type] ?? 0) + 1;
    }
    return map;
  }

  List<Map<String, dynamic>> get topDrivers {
    final Map<String, Map<String, dynamic>> map = {};
    for (final b in bookings.where(
      (b) => b.status == 'completed' && b.driver != null,
    )) {
      final id = b.driver!.id;
      final name = b.driver!.user.fullName.isNotEmpty
          ? b.driver!.user.fullName
          : b.driver!.user.userName;
      if (!map.containsKey(id)) {
        map[id] = {'name': name, 'trips': 0, 'revenue': 0.0};
      }
      map[id]!['trips'] = (map[id]!['trips'] as int) + 1;
      map[id]!['revenue'] = (map[id]!['revenue'] as double) + b.price;
    }
    final list = map.values.toList()
      ..sort((a, b) => (b['trips'] as int).compareTo(a['trips'] as int));
    return list;
  }

  double get averagePrice {
    final completed = bookings.where((b) => b.status == 'completed').toList();
    if (completed.isEmpty) return 0;
    return completed.fold(0.0, (sum, b) => sum + b.price) / completed.length;
  }

  Map<String, double> revenueAnalysisByMonth(int month, {int? year}) {
    final now = DateTime.now();
    final filtered = bookings.where((b) {
      final t = b.bookingTime.toLocal();
      return b.status == 'completed' &&
          t.month == month &&
          t.year == (year ?? now.year);
    }).toList();

    if (filtered.isEmpty) return {'total': 0, 'average': 0, 'count': 0};

    final total = filtered.fold(0.0, (sum, b) => sum + b.price);

    return {
      'total': total,
      'average': total / filtered.length,
      'count': filtered.length.toDouble(),
    };
  }
}
