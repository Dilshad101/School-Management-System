import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../../../shared/widgets/buttons/micro_delete_button.dart';
import '../../../../../shared/widgets/buttons/micro_edit_button.dart';
import '../../../models/employee_model.dart';

class EmployeeTile extends StatelessWidget {
  const EmployeeTile({
    super.key,
    required this.employee,
    this.onEdit,
    this.onDelete,
  });

  final EmployeeModel employee;
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
              _buildProfileImage(),
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
                            employee.fullName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (employee.isActive)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.green.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            child: Text(
                              'Active',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        if (employee.primaryRole != null) ...[
                          Text(
                            employee.primaryRole!,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 18,
                            child: VerticalDivider(color: AppColors.border),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            employee.displayId,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary.withAlpha(160),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (employee.email.isNotEmpty)
                      Text(
                        employee.email,
                        style: AppTextStyles.bodyMedium.apply(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildProfileImage() {
    if (employee.profilePicUrl != null) {
      return Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.border.withAlpha(50),
          image: DecorationImage(
            image: NetworkImage(employee.profilePicUrl!),
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
}
