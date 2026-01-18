import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';

/// Data model for fee collection
class FeeCollectionData {
  final String month;
  final double bankAmount;
  final double cashAmount;

  const FeeCollectionData({
    required this.month,
    required this.bankAmount,
    required this.cashAmount,
  });

  double get total => bankAmount + cashAmount;
}

class FeeCollectionChart extends StatelessWidget {
  const FeeCollectionChart({super.key, this.data, this.isLoading = false});

  final List<FeeCollectionData>? data;
  final bool isLoading;

  // Default sample data
  static const List<FeeCollectionData> _defaultData = [
    FeeCollectionData(month: 'Jan', bankAmount: 60000, cashAmount: 40000),
    FeeCollectionData(month: 'Feb', bankAmount: 72000, cashAmount: 48000),
    FeeCollectionData(month: 'Mar', bankAmount: 102000, cashAmount: 84000),
    FeeCollectionData(month: 'Apr', bankAmount: 90000, cashAmount: 66000),
    FeeCollectionData(month: 'May', bankAmount: 72000, cashAmount: 54000),
    FeeCollectionData(month: 'Jun', bankAmount: 84000, cashAmount: 60000),
  ];

  List<FeeCollectionData> get _chartData => data ?? _defaultData;

  double get _totalBank =>
      _chartData.fold(0, (sum, item) => sum + item.bankAmount);

  double get _totalCash =>
      _chartData.fold(0, (sum, item) => sum + item.cashAmount);

  double get _maxY {
    if (_chartData.isEmpty) return 120000;
    final maxValue = _chartData
        .map((d) => d.bankAmount > d.cashAmount ? d.bankAmount : d.cashAmount)
        .reduce((a, b) => a > b ? a : b);
    // Round up to nearest 20k for cleaner axis
    return ((maxValue / 20000).ceil() * 20000).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading ? _buildLoadingState() : _buildChartContent(),
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
        // Header with legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fee Collection',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                _buildLegendItem(
                  'Bank (${_formatAmount(_totalBank)})',
                  AppColors.primary,
                ),
                const SizedBox(width: 12),
                _buildLegendItem(
                  'Cash (${_formatAmount(_totalCash)})',
                  AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Chart
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _maxY,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.black87,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final data = _chartData[groupIndex];
                    final isBank = rodIndex == 0;
                    return BarTooltipItem(
                      '${isBank ? 'Bank' : 'Cash'}\n${_formatAmount(isBank ? data.bankAmount : data.cashAmount)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => _buildBottomTitle(value),
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => _buildLeftTitle(value),
                    reservedSize: 40,
                    interval: _maxY / 5,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _maxY / 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.border.withAlpha(100),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(),
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(_chartData.length, (index) {
      final item = _chartData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.bankAmount,
            color: AppColors.primary,
            width: 10,
            borderRadius: BorderRadius.circular(12),
          ),
          BarChartRodData(
            toY: item.cashAmount,
            color: AppColors.secondary,
            width: 10,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  Widget _buildBottomTitle(double value) {
    final index = value.toInt();
    if (index < 0 || index >= _chartData.length) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _chartData[index].month,
        style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildLeftTitle(double value) {
    return Text(
      _formatAmount(value),
      style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
