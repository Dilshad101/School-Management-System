import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/auth/permissions.dart';
import 'package:school_management_system/features/auth/blocs/user/user_bloc.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
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
          // Subject Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Name
                Text(
                  subject.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Code and Lab Status Row
                Row(
                  children: [
                    // Code
                    _InfoColumn(label: 'Code', value: subject.code ?? '-'),
                    const SizedBox(width: 32),
                    // Lab Status
                    _InfoColumn(
                      label: 'Lab',
                      value: subject.isLab ? 'Yes' : 'No',
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
                Permissions.changeSubject,
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
                Permissions.deleteSubject,
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
