import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../models/employee_model.dart';

/// Section showing employee information fields.
class EmployeeInfoSection extends StatelessWidget {
  const EmployeeInfoSection({super.key, required this.employee});

  final EmployeeModel employee;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Teacher Information',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        // Info fields
        _InfoField(label: 'Mobile No', value: employee.phone ?? '---'),
        _InfoField(
          label: 'Joined Date',
          value: _formatDate(employee.profile?.createdAt),
        ),
        _InfoField(label: 'Gender', value: employee.profile?.gender ?? '---'),
        _InfoField(
          label: 'Blood Group',
          value: employee.profile?.bloodGroup ?? '---',
        ),
        _InfoField(label: 'Address', value: employee.profile?.address ?? '---'),
        _InfoField(label: 'Email', value: employee.email),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '---';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '---';
    }
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // Value container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
