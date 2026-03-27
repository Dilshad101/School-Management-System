import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';

/// Read-only info field widget for displaying student details.
class InfoField extends StatelessWidget {
  const InfoField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            value.isEmpty ? '---' : value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: value.isEmpty
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
