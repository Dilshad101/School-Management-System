import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../models/student_model.dart';

/// Header widget showing student profile info.
class StudentHeader extends StatelessWidget {
  const StudentHeader({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
    required this.isEditMode,
    required this.onToggleActive,
  });

  final StudentModel student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isEditMode;
  final ValueChanged<bool> onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile picture with edit/delete buttons
        Stack(
          children: [
            // Profile picture
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      student.profilePicUrl != null &&
                          student.profilePicUrl!.isNotEmpty
                      ? Image.network(
                          student.profilePicUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.background,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _DefaultAvatar(),
                        )
                      : _DefaultAvatar(),
                ),
              ),
            ),
            // Edit/Delete buttons
            // Positioned(
            //   right: 0,
            //   top: 0,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: [
            //       // _ActionButton(
            //       //   icon: Icons.edit_outlined,
            //       //   label: 'Edit',
            //       //   color: AppColors.primary,
            //       //   onTap: onEdit,
            //       // ),
            //       // const SizedBox(height: 8),
            //       _ActionButton(
            //         icon: Icons.delete_outline,
            //         label: 'Delete',
            //         color: AppColors.borderError,
            //         onTap: onDelete,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 16),
        // Student name
        Text(
          student.fullName,
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Class and ID
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              student.classroomName ??
                  student.enrollment?.classroomName ??
                  '---',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' | ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'ID ${student.enrollment?.rollNo ?? student.commonId ?? '---'}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Active status
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Active',
              style: AppTextStyles.bodyMedium.copyWith(
                color: student.isActive
                    ? AppColors.green
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: student.isActive,
              onChanged: isEditMode ? onToggleActive : null,
              activeColor: AppColors.green,
            ),
          ],
        ),
      ],
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Icon(Icons.person, size: 48, color: AppColors.textSecondary),
    );
  }
}

// class _ActionButton extends StatelessWidget {
//   const _ActionButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 16, color: color),
//             const SizedBox(width: 4),
//             Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
//           ],
//         ),
//       ),
//     );
//   }
// }
