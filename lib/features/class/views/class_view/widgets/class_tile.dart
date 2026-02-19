import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';

import '../../../../../shared/styles/app_styles.dart';

class ClassTile extends StatelessWidget {
  const ClassTile({
    super.key,
    this.className = 'Class 10 - A',
    this.classId = 'class_10_a',
    this.roomNumber = 'Room A-12',
    this.teacherName = 'Ms. johnson',
    this.studentCount = 36,
    this.subjectCount = 8,
    this.hasTimetable = true,
    this.daysLeft,
    this.onManageTimetable,
  });

  final String className, classId;
  final String roomNumber;
  final String teacherName;
  final int studentCount;
  final int subjectCount;
  final bool hasTimetable;
  final int? daysLeft;
  final VoidCallback? onManageTimetable;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(Routes.classDetail, extra: classId);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class name and room number row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  className,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  roomNumber,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Teacher name
            Text(
              'Teacher: $teacherName',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary.withAlpha(150),
              ),
            ),
            const SizedBox(height: 6),

            // Students and subjects count row
            Row(
              children: [
                // Students count
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school, size: 22, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '$studentCount Students',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary.withAlpha(150),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(width: 16),

                // // Subjects count
                // Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     Icon(Icons.book, size: 22, color: AppColors.primary),
                //     const SizedBox(width: 6),
                //     Text(
                //       '$subjectCount Subjects',
                //       style: AppTextStyles.bodySmall.copyWith(
                //         color: AppColors.textPrimary.withAlpha(150),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),

            // Bottom action row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (daysLeft != null && !hasTimetable)
                  _buildDaysLeftBadge()
                else
                  _buildManageTimetableButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageTimetableButton() {
    return InkWell(
      onTap: onManageTimetable,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.table_chart_outlined, size: 20, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            'Manage Timetable',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysLeftBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 18, color: Colors.red),
        const SizedBox(width: 6),
        Text(
          '$daysLeft days Left',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
