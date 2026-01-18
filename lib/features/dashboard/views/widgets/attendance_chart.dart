import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:school_management_system/shared/widgets/text/gradiant_text.dart';

import '../../../../shared/styles/app_styles.dart';

/// Data model for attendance
class AttendanceData {
  final String day;
  final double percentage;

  const AttendanceData({required this.day, required this.percentage});
}

/// Time range options for attendance chart
enum AttendanceTimeRange {
  last7Days('Last 7 days'),
  thisMonth('This Month'),
  lastMonth('Last Month');

  final String label;
  const AttendanceTimeRange(this.label);
}

class AttendanceChart extends StatefulWidget {
  const AttendanceChart({
    super.key,
    this.data,
    this.overallPercentage,
    this.percentageChange,
    this.isLoading = false,
    this.onTimeRangeChanged,
  });

  final List<AttendanceData>? data;
  final double? overallPercentage;
  final double? percentageChange;
  final bool isLoading;
  final ValueChanged<AttendanceTimeRange>? onTimeRangeChanged;

  @override
  State<AttendanceChart> createState() => _AttendanceChartState();
}

class _AttendanceChartState extends State<AttendanceChart> {
  int _selectedDayIndex = 3;
  AttendanceTimeRange _selectedTimeRange = AttendanceTimeRange.last7Days;

  // Default sample data
  static const List<AttendanceData> _defaultData = [
    AttendanceData(day: 'Mon', percentage: 92),
    AttendanceData(day: 'Tue', percentage: 88),
    AttendanceData(day: 'Wed', percentage: 95),
    AttendanceData(day: 'Thu', percentage: 85),
    AttendanceData(day: 'Fri', percentage: 91),
    AttendanceData(day: 'Sat', percentage: 98),
  ];

  List<AttendanceData> get _chartData => widget.data ?? _defaultData;
  double get _overallPercentage => widget.overallPercentage ?? 98;
  double get _percentageChange => widget.percentageChange ?? 11.01;

  double get _minY {
    if (_chartData.isEmpty) return 0;
    final minValue = _chartData
        .map((d) => d.percentage)
        .reduce((a, b) => a < b ? a : b);
    return (minValue - 10).clamp(0, 100);
  }

  double get _maxY {
    if (_chartData.isEmpty) return 100;
    final maxValue = _chartData
        .map((d) => d.percentage)
        .reduce((a, b) => a > b ? a : b);
    return (maxValue + 5).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: widget.isLoading ? _buildLoadingState() : _buildChartContent(),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildChartContent() {
    if (_chartData.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No data available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Attendance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${_overallPercentage.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_percentageChange >= 0 ? '+' : ''}${_percentageChange.toStringAsFixed(2)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _percentageChange >= 0
                            ? AppColors.green
                            : Colors.red,
                        fontSize: 11,
                      ),
                    ),
                    Icon(
                      _percentageChange >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: _percentageChange >= 0
                          ? AppColors.green
                          : Colors.red,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
            _buildTimeRangeDropdown(),
          ],
        ),
        const SizedBox(height: 20),
        // Chart area
        SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              minY: _minY,
              maxY: _maxY,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.black87,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                touchCallback: (event, response) {
                  if (response?.lineBarSpots != null &&
                      response!.lineBarSpots!.isNotEmpty) {
                    final spotIndex = response.lineBarSpots!.first.spotIndex;
                    if (event is FlTapUpEvent &&
                        spotIndex != _selectedDayIndex) {
                      setState(() {
                        _selectedDayIndex = spotIndex;
                      });
                    }
                  }
                },
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (_maxY - _minY) / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.border.withAlpha(80),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                // days of the week at bottom
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    interval: 1,
                    showTitles: true,

                    /// show only titles for the selected day
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= _chartData.length) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _selectedDayIndex == index
                            ? GradientText(
                                _chartData[index].day,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Text(
                                _chartData[index].day,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),

              lineBarsData: [
                LineChartBarData(
                  spots: _buildSpots(),
                  isCurved: true,
                  curveSmoothness: 0.35,
                  gradient: AppColors.primaryGradient,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      final isSelected = index == _selectedDayIndex;
                      return FlDotCirclePainter(
                        radius: isSelected ? 6 : 0,
                        color: AppColors.primary,
                        strokeWidth: 3,
                        strokeColor: isSelected
                            ? AppColors.white
                            : Colors.transparent,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withAlpha(90),
                        AppColors.primary.withAlpha(10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
        const SizedBox(height: 16),
        // // Day selector
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: List.generate(_chartData.length, (index) {
        //     final isSelected = index == _selectedDayIndex;
        //     return GestureDetector(
        //       onTap: () {
        //         setState(() {
        //           _selectedDayIndex = index;
        //         });
        //       },
        //       child: Container(
        //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //         child: isSelected
        //             ? GradientText(
        //                 _chartData[index].day,
        //                 style: AppTextStyles.bodySmall.copyWith(
        //                   fontWeight: FontWeight.w600,
        //                 ),
        //               )
        //             : Text(
        //                 _chartData[index].day,
        //                 style: AppTextStyles.bodySmall.copyWith(
        //                   color: AppColors.textSecondary,
        //                   fontWeight: FontWeight.normal,
        //                 ),
        //               ),
        //       ),
        //     );
        //   }),
        // ),
      ],
    );
  }

  List<FlSpot> _buildSpots() {
    return List.generate(_chartData.length, (index) {
      return FlSpot(index.toDouble(), _chartData[index].percentage);
    });
  }

  Widget _buildTimeRangeDropdown() {
    return PopupMenuButton<AttendanceTimeRange>(
      onSelected: (value) {
        setState(() {
          _selectedTimeRange = value;
        });
        widget.onTimeRangeChanged?.call(value);
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => AttendanceTimeRange.values
          .map(
            (range) => PopupMenuItem(
              value: range,
              child: Text(
                range.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: range == _selectedTimeRange
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: range == _selectedTimeRange
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedTimeRange.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
