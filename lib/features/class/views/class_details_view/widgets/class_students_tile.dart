import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../../students/models/student_model.dart';

class ClassStudentTile extends StatelessWidget {
  const ClassStudentTile({super.key, required this.student, this.onTap});

  final StudentModel student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final guardian = student.guardians.isNotEmpty
        ? student.guardians.first
        : null;
    final rollNo = student.enrollment?.rollNo ?? student.commonId ?? '---';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.border.withAlpha(50),
                image: student.profilePicUrl != null
                    ? DecorationImage(
                        image: NetworkImage(student.profilePicUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: student.profilePicUrl == null
                  ? Center(
                      child: Text(
                        student.fullName.isNotEmpty
                            ? student.fullName[0].toUpperCase()
                            : 'S',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textPrimary.withAlpha(160),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Student info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Name and active status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          student.fullName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (student.isActive)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.green.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            'Active',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Class and Roll number
                  Row(
                    children: [
                      Text(
                        student.classroomName ?? '---',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                        child: VerticalDivider(color: AppColors.border),
                      ),
                      Text(
                        'Roll: $rollNo',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                  // Guardian info (if available)
                  if (guardian != null) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: 'GDN: ',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary.withAlpha(160),
                        ),
                        children: [
                          TextSpan(
                            text: guardian.fullName,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (guardian.phone != null) ...[
                            TextSpan(
                              text: ' • ',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textPrimary.withAlpha(160),
                              ),
                            ),
                            TextSpan(
                              text: guardian.phone!,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textPrimary.withAlpha(160),
                              ),
                            ),
                          ],
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Arrow icon
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
