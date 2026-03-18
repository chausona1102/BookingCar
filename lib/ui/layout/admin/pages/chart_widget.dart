import 'package:booking_app/utils/myFunction.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booking_app/ui/layout/admin/manager/statistical_manager.dart';

class RevenueLineChart extends StatefulWidget {
  final int year;
  const RevenueLineChart({super.key, required this.year});

  @override
  State<RevenueLineChart> createState() => _RevenueLineChartState();
}

class _RevenueLineChartState extends State<RevenueLineChart> {
  late List<FlSpot> spots;
  double maxY = 0;
  int _selectedYear = DateTime.now().year;
  int yearNow = DateTime.now().year;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildSpots();
  }

  // void _buildSpots() {
  //   final m = context.read<StatisticalManager>();
  //   spots = List.generate(12, (i) {
  //     final month = i + 1;
  //     final total =
  //         m.revenueAnalysisByMonth(month, year: widget.year)['total'] ?? 0;
  //     if (total > maxY) maxY = total;
  //     return FlSpot(month.toDouble(), total);
  //   });
  //   if (maxY == 0) maxY = 100000;
  // }
  void _buildSpots() {
    final m = context.read<StatisticalManager>();
    maxY = 0;
    spots = List.generate(12, (i) {
      final month = i + 1;
      final total =
          m.revenueAnalysisByMonth(month, year: _selectedYear)['total'] ?? 0;
      if (total > maxY) maxY = total.toDouble();
      return FlSpot(month.toDouble(), total.toDouble());
    });
    if (maxY == 0) maxY = 100000;
  }

  @override
  Widget build(BuildContext context) {
    final myFns = context.read<MyFunctions>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                Text(
                  'Doanh thu $_selectedYear',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildYearPicker(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 12,
                minY: 0,
                maxY: maxY * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: maxY / 4,
                      getTitlesWidget: (value, _) => Text(
                        myFns.formatShort(value),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) => Text(
                        'T${value.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map(
                          (s) => LineTooltipItem(
                            'T${s.x.toInt()}\n${myFns.formatVND(s.y)}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: spot.y > 0 ? 5 : 3,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: Colors.green,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.25),
                          Colors.green.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildYearPicker() {
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
              value: _selectedYear,
              isDense: true,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: [yearNow - 3, yearNow - 2, yearNow - 1, yearNow]
                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedYear = v!;
                _buildSpots();
              }),
            ),
          ),
        ),
      ],
    );
  }
}
