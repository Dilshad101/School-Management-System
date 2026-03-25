import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/core/utils/helpers.dart';
import 'package:school_management_system/features/class/models/classroom_model.dart';
import 'package:school_management_system/shared/widgets/buttons/micro_delete_button.dart';
import 'package:school_management_system/shared/widgets/buttons/micro_edit_button.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../blocs/classroom/classroom_bloc.dart';

class ClassTile extends StatelessWidget {
  const ClassTile({
    super.key,
    required this.classroom,
    this.hasTimetable = true,
    this.daysLeft,
    this.onManageTimetable,
  });

  final ClassroomModel classroom;
  final bool hasTimetable;
  final int? daysLeft;
  final VoidCallback? onManageTimetable;

  @override
  Widget build(BuildContext context) {
    final teacherName = classroom.classTeacherDetails?.name ?? 'Not assigned';

    return InkWell(
      onTap: () {
        context.push(Routes.classDetail, extra: classroom.id);
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
            // Class name and code row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    classroom.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    classroom.code.toUpperCase(),
                    textAlign: TextAlign.end,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      overflow: TextOverflow.ellipsis,
                    ),
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

            // Students count row
            Row(
              children: [
                // Students count
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school, size: 22, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${classroom.studentCount} Students',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary.withAlpha(150),
                      ),
                    ),
                  ],
                ),
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
                if (daysLeft != null && !hasTimetable) _buildDaysLeftBadge(),
                // else
                // _buildManageTimetableButton(),
                MicroEditButton(
                  onTap: () {
                    log(classroom.id);
                    context.push(Routes.editClass, extra: classroom.id);
                  },
                ),
                MicroDeleteButton(
                  onTap: () {
                    Helpers.showWarningBottomSheet(
                      context,
                      title: 'Delete Class',
                      message: 'Are you sure you want to delete this class?',
                      confirmText: 'Delete',
                      onConfirm: () {
                        context.read<ClassroomBloc>().add(
                          DeleteClassroom(classroom.id),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildManageTimetableButton() {
  //   return InkWell(
  //     onTap: onManageTimetable,
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(Icons.table_chart_outlined, size: 20, color: Colors.blue),
  //         const SizedBox(width: 6),
  //         Text(
  //           'Manage Timetable',
  //           style: AppTextStyles.bodyMedium.copyWith(
  //             color: Colors.blue,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
