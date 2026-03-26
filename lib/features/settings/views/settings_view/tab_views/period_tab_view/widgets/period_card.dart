import 'package:flutter/material.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../models/period_model.dart';

class PeriodCard extends StatelessWidget {
  final PeriodModel periodModel;
  final VoidCallback? onEdit;

  const PeriodCard({super.key, required this.periodModel, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Title
                Text(
                  'Order ${periodModel.order}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Time Row
                Row(
                  children: [
                    // Start Time
                    _TimeColumn(
                      label: 'Start Time',
                      value: periodModel.formattedStartTime,
                    ),
                    const SizedBox(width: 32),
                    // End Time
                    _TimeColumn(
                      label: 'End Time',
                      value: periodModel.formattedEndTime,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit Icon
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final String? value;

  const _TimeColumn({required this.label, this.value});

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
        const SizedBox(height: 4),
        Text(
          value ?? '__ /__',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: value != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
