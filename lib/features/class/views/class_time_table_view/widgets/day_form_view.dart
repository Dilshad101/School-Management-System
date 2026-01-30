import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/features/class/blocs/timetable/timetable_cubit.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

import 'period_item.dart';

/// The form view for entering periods for a specific day.
class DayFormView extends StatelessWidget {
  const DayFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableCubit, TimetableState>(
      builder: (context, state) {
        final periods = state.currentDayPeriods;
        final cubit = context.read<TimetableCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day title
              Text(state.currentDayName, style: AppTextStyles.heading4),
              const SizedBox(height: 16),

              // Period list
              if (periods.isNotEmpty) ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: periods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return PeriodItem(
                      periodNumber: index + 1,
                      period: periods[index],
                      teachers: state.teachers,
                      onSubjectChanged: (value) =>
                          cubit.updatePeriodSubject(index, value),
                      onTeacherChanged: (teacher) =>
                          cubit.updatePeriodTeacher(index, teacher),
                      onRemove: periods.length > 0
                          ? () => cubit.removePeriod(index)
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Add Period button
              _AddPeriodButton(onPressed: () => cubit.addPeriod()),
            ],
          ),
        );
      },
    );
  }
}

/// Add Period button widget.
class _AddPeriodButton extends StatelessWidget {
  const _AddPeriodButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.secondary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Add Period',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
