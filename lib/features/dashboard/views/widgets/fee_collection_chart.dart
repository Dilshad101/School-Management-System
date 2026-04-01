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
  const FeeCollectionChart({
    super.key,
    this.data,
    this.isLoading = false,
    this.hasError = false,
  });

  final List<FeeCollectionData>? data;
  final bool isLoading;
  final bool hasError;

  List<FeeCollectionData> get _chartData => data ?? [];

  bool get _hasData => data != null && data!.isNotEmpty;

  double get _totalBank =>
      _chartData.fold(0, (sum, item) => sum + item.bankAmount);

  double get _totalCash =>
      _chartData.fold(0, (sum, item) => sum + item.cashAmount);

  /// Calculates appropriate interval for Y-axis based on max value.
  double get _yInterval {
    final maxVal = _maxY;
    if (maxVal <= 0) return 1;

    // Calculate a nice interval that gives us ~5 labels
    final rawInterval = maxVal / 5;

    // Find the appropriate rounding factor
    if (rawInterval >= 100000) {
      return (rawInterval / 100000).ceil() * 100000;
    } else if (rawInterval >= 10000) {
      return (rawInterval / 10000).ceil() * 10000;
    } else if (rawInterval >= 1000) {
      return (rawInterval / 1000).ceil() * 1000;
    } else if (rawInterval >= 100) {
      return (rawInterval / 100).ceil() * 100;
    } else if (rawInterval >= 10) {
      return (rawInterval / 10).ceil() * 10;
    }
    return rawInterval.ceilToDouble();
  }

  double get _maxY {
    if (_chartData.isEmpty) return 100;
    final maxValue = _chartData
        .map((d) => d.bankAmount > d.cashAmount ? d.bankAmount : d.cashAmount)
        .reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) return 100;

    // Dynamically calculate round-up factor based on magnitude
    double roundFactor;
    if (maxValue >= 100000) {
      roundFactor = 50000;
    } else if (maxValue >= 10000) {
      roundFactor = 5000;
    } else if (maxValue >= 1000) {
      roundFactor = 500;
    } else if (maxValue >= 100) {
      roundFactor = 50;
    } else if (maxValue >= 10) {
      roundFactor = 5;
    } else {
      roundFactor = 1;
    }

    return ((maxValue / roundFactor).ceil() * roundFactor).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading
          ? _buildLoadingState()
          : hasError
          ? _buildErrorState()
          : !_hasData
          ? _buildEmptyState()
          : _buildChartContent(),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.borderError.withAlpha(150),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load fee collection data',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: AppColors.textSecondary.withAlpha(100),
            ),
            const SizedBox(height: 12),
            Text(
              'No fee collection data available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
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
                    interval: _yInterval,
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
                horizontalInterval: _yInterval,
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
