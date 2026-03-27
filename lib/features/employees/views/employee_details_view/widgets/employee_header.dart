import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../models/employee_model.dart';

/// Header widget showing employee profile info.
class EmployeeHeader extends StatelessWidget {
  const EmployeeHeader({
    super.key,
    required this.employee,
    required this.isTogglingActive,
    required this.onToggleActive,
  });

  final EmployeeModel employee;
  final bool isTogglingActive;
  final ValueChanged<bool> onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  employee.profilePicUrl != null &&
                      employee.profilePicUrl!.isNotEmpty
                  ? Image.network(
                      employee.profilePicUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.background,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const _DefaultAvatar(),
                    )
                  : const _DefaultAvatar(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Employee name
        Text(
          employee.fullName,
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Role and ID
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (employee.primaryRole != null) ...[
              Text(
                employee.primaryRole!,
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
            ],
            Text(
              'ID ${employee.id.substring(0, 5).toUpperCase()}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Active status with switch
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Active',
              style: AppTextStyles.bodyMedium.copyWith(
                color: employee.isActive
                    ? AppColors.green
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            if (isTogglingActive)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Switch(
                value: employee.isActive,
                onChanged: onToggleActive,
                activeColor: AppColors.green,
              ),
          ],
        ),
      ],
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(Icons.person, size: 48, color: AppColors.textSecondary),
      ),
    );
  }
}
