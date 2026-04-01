import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/auth/permissions.dart';
import 'package:school_management_system/features/auth/blocs/user/user_bloc.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../models/fee_component_model.dart';

class FeeComponentCard extends StatelessWidget {
  final FeeComponentModel feeComponent;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FeeComponentCard({
    super.key,
    required this.feeComponent,
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
          // Fee Component Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  feeComponent.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Type and Frequency Row
                Row(
                  children: [
                    // Type
                    _InfoColumn(
                      label: 'Type',
                      value: feeComponent.typeDisplayName,
                      valueColor: feeComponent.isOptional
                          ? AppColors.textSecondary
                          : AppColors.green,
                    ),
                    const SizedBox(width: 32),
                    // Frequency
                    _InfoColumn(
                      label: 'Frequency',
                      value: feeComponent.frequency.displayName,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Icons
          if (context.read<UserBloc>().state.hasPermission(
            Permissions.changeFee,
          ))
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(width: 8),
                // Delete Icon
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

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

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
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
