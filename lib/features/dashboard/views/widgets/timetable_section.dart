import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../models/dashboard_models.dart';

/// Section header with title and view all button.
class TimetableSection extends StatelessWidget {
  const TimetableSection({
    super.key,
    required this.periods,
    this.title = 'Timetable',
    this.isLoading = false,
    this.onViewAll,
  });

  final List<TimetablePeriod> periods;
  final String title;
  final bool isLoading;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // TextButton(
              //   onPressed: onViewAll,
              //   style: TextButton.styleFrom(
              //     padding: EdgeInsets.zero,
              //     minimumSize: const Size(0, 0),
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   ),
              //   child: Text(
              //     'View All',
              //     style: AppTextStyles.bodySmall.copyWith(
              //       color: AppColors.primary,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          if (isLoading)
            _buildLoadingState()
          else if (periods.isEmpty)
            _buildEmptyState()
          else
            _buildPeriodsList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
          child: _TimetablePeriodShimmer(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 48,
              color: AppColors.textSecondary.withAlpha(100),
            ),
            const SizedBox(height: 8),
            Text(
              'No timetable for today',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodsList() {
    return Column(
      children: periods.map((period) {
        final isLast = period == periods.last;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: _TimetablePeriodTile(period: period),
        );
      }).toList(),
    );
  }
}

/// Individual timetable period tile.
class _TimetablePeriodTile extends StatelessWidget {
  const _TimetablePeriodTile({required this.period});

  final TimetablePeriod period;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period info column
        SizedBox(
          width: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Period ${period.periodNumber}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                period.startTime,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                period.endTime,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Vertical divider
        Container(
          width: 1,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          color: AppColors.border,
        ),
        // Subject info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period.subjectName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${period.className}, ${period.roomName}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Status badge
        _StatusBadge(status: period.status),
      ],
    );
  }
}

/// Status badge for timetable period.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TimetablePeriodStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: _showBorder ? Border.all(color: _borderColor) : null,
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case TimetablePeriodStatus.completed:
        return 'Completed';
      case TimetablePeriodStatus.liveNow:
        return 'Live Now';
      case TimetablePeriodStatus.upcoming:
        return 'Upcoming';
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case TimetablePeriodStatus.completed:
        return AppColors.green.withAlpha(20);
      case TimetablePeriodStatus.liveNow:
        return AppColors.green;
      case TimetablePeriodStatus.upcoming:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    switch (status) {
      case TimetablePeriodStatus.completed:
        return AppColors.green;
      case TimetablePeriodStatus.liveNow:
        return Colors.white;
      case TimetablePeriodStatus.upcoming:
        return AppColors.textSecondary;
    }
  }

  Color get _borderColor {
    switch (status) {
      case TimetablePeriodStatus.completed:
        return Colors.transparent;
      case TimetablePeriodStatus.liveNow:
        return Colors.transparent;
      case TimetablePeriodStatus.upcoming:
        return AppColors.border;
    }
  }

  bool get _showBorder => status == TimetablePeriodStatus.upcoming;
}

/// Shimmer loading state for timetable period.
class _TimetablePeriodShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period info column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.border.withAlpha(100),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.border.withAlpha(100),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 50,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.border.withAlpha(100),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        Container(
          width: 1,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          color: AppColors.border,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.border.withAlpha(100),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 140,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.border.withAlpha(100),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 70,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.border.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}
