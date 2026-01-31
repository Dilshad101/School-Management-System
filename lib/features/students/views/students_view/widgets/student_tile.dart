import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../../../shared/widgets/buttons/micro_delete_button.dart';
import '../../../../../shared/widgets/buttons/micro_edit_button.dart';
import '../../../models/student_model.dart';

class StudentTile extends StatelessWidget {
  const StudentTile({
    super.key,
    required this.student,
    this.onEdit,
    this.onDelete,
  });

  final StudentModel student;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              _buildAvatar(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: Text(
                            student.fullName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          _getRoleName(),
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 18,
                          child: VerticalDivider(color: AppColors.border),
                        ),
                        Text(
                          'ID ${student.id}',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary.withAlpha(160),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: AppColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              MicroDeleteButton(onTap: onDelete),
              MicroEditButton(onTap: onEdit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final profilePic = student.profilePicUrl;
    if (profilePic != null && profilePic.isNotEmpty) {
      return Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.border.withAlpha(50),
          image: DecorationImage(
            image: NetworkImage(profilePic),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.border.withAlpha(50),
      ),
      child: Icon(
        Icons.person,
        size: 32,
        color: AppColors.textPrimary.withAlpha(160),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isActive = student.isActive;
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.green.withAlpha(20)
            : AppColors.borderError.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          color: isActive ? AppColors.green : AppColors.borderError,
        ),
      ),
    );
  }

  String _getRoleName() {
    if (student.rolesDetails.isNotEmpty) {
      return student.rolesDetails.first.roleName;
    }
    return 'Student';
  }
}
