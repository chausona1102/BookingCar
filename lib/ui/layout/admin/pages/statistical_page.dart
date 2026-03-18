import 'package:booking_app/ui/layout/admin/manager/statistical_manager.dart';
import 'package:booking_app/ui/layout/admin/pages/chart_widget.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/utils/myFunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

class StatisticalPage extends StatefulWidget {
  const StatisticalPage({super.key});

  @override
  State<StatisticalPage> createState() => _StatisticalPageState();
}

class _StatisticalPageState extends State<StatisticalPage> {
  final logger = Logger();
  late final StatisticalManager statisticalManager;
  bool _isLoading = true;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int yearNow = DateTime.now().year;
  late final MyFunctions myFns;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      statisticalManager = context.read<StatisticalManager>();
      myFns = context.read<MyFunctions>();
      await statisticalManager.fetchAllBookings();
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<StatisticalManager>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: myAppBar(context, 'Thống kê'),
      body: _isLoading
          ? const Center(child: SpinKitCircle(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCards(),
                  const SizedBox(height: 20),
                  _buildMonthlyAnalysis(),
                  const SizedBox(height: 20),
                  RevenueLineChart(year: yearNow),
                  const SizedBox(height: 20),
                  _buildStatusBreakdown(),
                  const SizedBox(height: 20),
                  _buildTopDrivers(),
                  const SizedBox(height: 20),
                  _buildVehicleType(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    final m = statisticalManager;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tổng quan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _statCard(
              label: 'Tổng doanh thu',
              value: myFns.formatVND(m.totalRevenue),
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _statCard(
              label: 'Tổng đơn',
              value: m.totalBookings.toString(),
              icon: Icons.receipt_long,
              color: Colors.blue,
            ),
            _statCard(
              label: 'Hoàn thành',
              value: '${m.completionRate.toStringAsFixed(1)}%',
              icon: Icons.check_circle_outline,
              color: Colors.teal,
            ),
            _statCard(
              label: 'Tỉ lệ huỷ',
              value: '${m.cancellationRate.toStringAsFixed(1)}%',
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyAnalysis() {
    final analysis = statisticalManager.revenueAnalysisByMonth(
      _selectedMonth,
      year: _selectedYear,
    );
    final total = analysis['total'] ?? 0;
    final average = analysis['average'] ?? 0;
    final count = (analysis['count'] ?? 0).toInt();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Doanh thu theo tháng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildMonthYearPicker(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _monthlyStatItem(
                  label: 'Tổng doanh thu',
                  value: myFns.formatVND(total),
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _monthlyStatItem(
                  label: 'Trung bình/đơn',
                  value: myFns.formatVND(average),
                  color: Colors.orange,
                  icon: Icons.bar_chart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _monthlyStatItem(
                  label: 'Số đơn',
                  value: count.toString(),
                  color: Colors.blue,
                  icon: Icons.receipt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthlyStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedMonth,
              isDense: true,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: List.generate(
                12,
                (i) => DropdownMenuItem(value: i + 1, child: Text('T${i + 1}')),
              ),
              onChanged: (v) => setState(() => _selectedMonth = v!),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              isDense: true,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: [yearNow - 3, yearNow - 2, yearNow - 1, yearNow]
                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                  .toList(),
              onChanged: (v) => setState(() => _selectedYear = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown() {
    final m = statisticalManager;
    final statuses = [
      ('Chờ xác nhận', m.pendingCount, Colors.orange),
      ('Đã xác nhận', m.acceptedCount, Colors.blue),
      ('Đang đi', m.ontripCount, Colors.cyan),
      ('Hoàn thành', m.completedCount, Colors.green),
      ('Đã huỷ', m.cancelledCount, Colors.red),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trạng thái đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...statuses.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(s.$1, style: const TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: m.totalBookings == 0
                            ? 0
                            : s.$2 / m.totalBookings,
                        backgroundColor: s.$3.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(s.$3),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${s.$2}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: s.$3,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDrivers() {
    final drivers = statisticalManager.topDrivers.take(5).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top tài xế',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (drivers.isEmpty)
            const Center(
              child: Text(
                'Chưa có dữ liệu',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...drivers.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: Text(
                        '${e.key + 1}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.value['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${e.value['trips']} chuyến',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          myFns.formatVND(e.value['revenue']),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVehicleType() {
    final types = statisticalManager.bookingsByType;
    final total = types.values.fold(0, (a, b) => a + b);
    final colors = {
      'car': Colors.blue,
      'motobike': Colors.orange,
      'driver': Colors.green,
    };
    final labels = {
      'car': '🚗 Ô tô',
      'motobike': '🏍 Xe máy',
      'driver': '👮 Tài xế',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loại phương tiện',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...types.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      labels[e.key] ?? e.key,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : e.value / total,
                        backgroundColor: (colors[e.key] ?? Colors.grey)
                            .withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(
                          colors[e.key] ?? Colors.grey,
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.value}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors[e.key] ?? Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
