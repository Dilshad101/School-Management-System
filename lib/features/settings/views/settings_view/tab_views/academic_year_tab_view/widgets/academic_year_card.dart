import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/auth/permissions.dart';
import 'package:school_management_system/features/auth/blocs/user/user_bloc.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../models/academic_year_model.dart';

class AcademicYearCard extends StatelessWidget {
  final AcademicYearModel academicYear;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AcademicYearCard({
    super.key,
    required this.academicYear,
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
          // Academic Year Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with current badge
                Row(
                  children: [
                    Text(
                      academicYear.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (academicYear.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Current',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Date Row
                Row(
                  children: [
                    // Start Date
                    _InfoColumn(
                      label: 'Start Date',
                      value: academicYear.formattedStartDate,
                    ),
                    const SizedBox(width: 32),
                    // End Date
                    _InfoColumn(
                      label: 'End Date',
                      value: academicYear.formattedEndDate,
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
              /// Only show if user has edit permission
              if (context.read<UserBloc>().state.hasPermission(
                Permissions.changeAcademicYear,
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
              /// Only show delete if user has permission
              if (context.read<UserBloc>().state.hasPermission(
                Permissions.deleteAcademicYear,
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

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

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
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
