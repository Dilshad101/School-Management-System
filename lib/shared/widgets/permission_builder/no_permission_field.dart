import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_colors.dart';
import 'package:school_management_system/shared/styles/app_text_styles.dart';

/// A disabled field widget shown when user lacks permission.
class NoPermissionField extends StatelessWidget {
  const NoPermissionField({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary.withAlpha(150), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No permission to view $label',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Icon(
            Icons.lock_outline,
            color: AppColors.textSecondary.withAlpha(150),
            size: 18,
          ),
        ],
      ),
    );
  }
}
