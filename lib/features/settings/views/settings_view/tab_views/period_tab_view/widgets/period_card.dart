import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/auth/permissions.dart';
import 'package:school_management_system/features/auth/blocs/user/user_bloc.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../models/period_model.dart';

class PeriodCard extends StatelessWidget {
  final PeriodModel periodModel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PeriodCard({
    super.key,
    required this.periodModel,
    this.onEdit,
    this.onDelete,
  });

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

          // Action Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Icon
              if (context.read<UserBloc>().state.hasPermission(
                Permissions.changePeriod,
              ))
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
              const SizedBox(width: 8),
              // Delete Icon
              if (context.read<UserBloc>().state.hasPermission(
                Permissions.deletePeriod,
              ))
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.borderError,
                    ),
                  ),
                ),
            ],
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
