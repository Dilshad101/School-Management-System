import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/features/class/blocs/timetable/timetable_cubit.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// Preview view showing all days' timetables with edit option.
class PreviewView extends StatelessWidget {
  const PreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableCubit, TimetableState>(
      builder: (context, state) {
        final allDays = state.allDaysTimetable;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: allDays.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final dayTimetable = allDays[index];
            return _DayPreviewCard(
              dayTimetable: dayTimetable,
              onEditPressed: () {
                context.read<TimetableCubit>().goToDay(dayTimetable.day);
              },
            );
          },
        );
      },
    );
  }
}

/// Card showing a single day's timetable in the preview.
class _DayPreviewCard extends StatelessWidget {
  const _DayPreviewCard({
    required this.dayTimetable,
    required this.onEditPressed,
  });

  final DayTimetable dayTimetable;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with day name and edit button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dayTimetable.dayName, style: AppTextStyles.heading4),
                _EditButton(onPressed: onEditPressed),
              ],
            ),
          ),

          // Table header
          if (dayTimetable.periods.isNotEmpty) ...[
            _buildTableHeader(),
            const Divider(height: 1),
            // Period rows
            ...List.generate(
              dayTimetable.periods.length,
              (index) => _buildPeriodRow(index, dayTimetable.periods[index]),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No periods added',
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.background),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Periods',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Subject',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Teacher',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(int index, PeriodModel period) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withAlpha(100), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              period.subject.isEmpty ? '-' : period.subject,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              period.teacherName ?? '-',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit button widget with icon and text.
class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(Icons.edit_outlined, color: AppColors.green, size: 18),
      label: Text(
        'Edit',
        style: AppTextStyles.labelMedium.copyWith(color: AppColors.green),
      ),
    );
  }
}
