import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/di.dart';
import '../../../../../shared/styles/app_styles.dart';
import '../../../blocs/class_timetable/class_timetable_cubit.dart';
import '../../../blocs/class_timetable/class_timetable_state.dart';
import '../../../models/timetable_model.dart';
import '../../../repositories/classroom_repository.dart';
import '../widgets/timetable_entry_bottom_sheet.dart';

class ClassTimetableTabView extends StatelessWidget {
  const ClassTimetableTabView({
    super.key,
    required this.classroomId,
    required this.academicYearId,
    required this.schoolId,
  });

  final String classroomId;
  final String academicYearId;
  final String schoolId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClassTimetableCubit(
        classroomRepository: locator<ClassroomRepository>(),
        classroomId: classroomId,
        academicYearId: academicYearId,
        schoolId: schoolId,
      )..fetchTimetable(),
      child: const _TimetableContent(),
    );
  }
}

class _TimetableContent extends StatelessWidget {
  const _TimetableContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClassTimetableCubit, ClassTimetableState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.isActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Timetable updated successfully'),
              backgroundColor: AppColors.green,
            ),
          );
          context.read<ClassTimetableCubit>().clearActionStatus();
        } else if (state.isActionFailure && state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.borderError,
            ),
          );
          context.read<ClassTimetableCubit>().clearActionStatus();
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildContent(context, state),
                  ),
                ),
              ],
            ),
            if (state.isActionLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ClassTimetableState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.borderError),
            const SizedBox(height: 16),
            Text(
              'Failed to load timetable',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.borderError,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  context.read<ClassTimetableCubit>().fetchTimetable(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No timetable found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Day header with navigation
        _DayHeader(
          dayName: state.selectedDayName,
          canGoPrevious: state.selectedDayIndex > 0,
          canGoNext:
              state.selectedDayIndex < ClassTimetableState.dayNames.length - 1,
          onPrevious: () => context.read<ClassTimetableCubit>().previousDay(),
          onNext: () => context.read<ClassTimetableCubit>().nextDay(),
        ),
        const SizedBox(height: 12),
        // Table header
        const _TableHeader(),
        const Divider(height: 1, color: AppColors.border),
        // Period rows
        Expanded(
          child: ListView.separated(
            itemCount: state.periods.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final period = state.periods[index];
              final entry = period.getEntryForDay(state.selectedDayIndex);
              return _TimetableRow(
                period: period,
                entry: entry,
                dayIndex: state.selectedDayIndex,
                dayName: state.selectedDayName,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String dayName;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _DayHeader({
    required this.dayName,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(dayName, style: AppTextStyles.heading4),
        Row(
          children: [
            _NavButton(
              icon: Icons.chevron_left,
              onTap: canGoPrevious ? onPrevious : null,
              enabled: canGoPrevious,
            ),
            const SizedBox(width: 8),
            _NavButton(
              icon: Icons.chevron_right,
              onTap: canGoNext ? onNext : null,
              enabled: canGoNext,
            ),
          ],
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _NavButton({required this.icon, this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.border.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Periods column
          SizedBox(
            width: 70,
            child: Text(
              'Periods',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Subject column
          Expanded(
            flex: 2,
            child: Text(
              'Subject',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Teacher column
          Expanded(
            flex: 2,
            child: Text(
              'Teacher',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableRow extends StatelessWidget {
  final PeriodWithTimetableModel period;
  final TimetableEntryModel? entry;
  final int dayIndex;
  final String dayName;

  const _TimetableRow({
    required this.period,
    this.entry,
    required this.dayIndex,
    required this.dayName,
  });

  bool get isAssigned => entry != null && entry!.isAssigned;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showEntryBottomSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Period number with time
            SizedBox(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${period.order}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (period.formattedStartTime.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      period.formattedStartTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Subject
            Expanded(
              flex: 2,
              child: Text(
                isAssigned ? (entry!.subjectName ?? '---') : '---',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isAssigned
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Teacher
            Expanded(
              flex: 2,
              child: Text(
                isAssigned ? (entry!.teacherName ?? '---') : '---',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isAssigned
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEntryBottomSheet(BuildContext context) async {
    final result = await TimetableEntryBottomSheet.show(
      context,
      periodName: 'Period ${period.order}',
      dayName: dayName,
      initialSubjectId: entry?.subjectId,
      initialSubjectName: entry?.subjectName,
      initialTeacherId: entry?.teacherId,
      initialTeacherName: entry?.teacherName,
      isEditing: isAssigned,
    );

    if (result != null && context.mounted) {
      context.read<ClassTimetableCubit>().saveTimetableEntry(
        periodId: period.id,
        dayOfWeek: dayIndex + 1, // API expects 1-based (Monday = 1)
        subjectId: result.subjectId,
        teacherId: result.teacherId,
      );
    }
  }
}
