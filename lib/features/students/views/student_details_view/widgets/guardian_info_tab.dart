import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../models/guardian_model.dart';
import 'info_field.dart';

/// Tab content for displaying guardian information.
class GuardianInfoTab extends StatelessWidget {
  const GuardianInfoTab({super.key, required this.guardians});

  final List<GuardianModel> guardians;

  @override
  Widget build(BuildContext context) {
    if (guardians.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No guardian information available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Show the first guardian (primary guardian)
    final guardian = guardians.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guardian Information', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          InfoField(label: 'Name', value: guardian.fullName),
          const SizedBox(height: 16),
          InfoField(label: 'Relation', value: guardian.relation ?? ''),
          const SizedBox(height: 16),
          InfoField(label: 'Phone NO', value: guardian.phone ?? ''),
          const SizedBox(height: 16),
          InfoField(label: 'Email', value: guardian.email ?? ''),
          // Show additional guardians if any
          if (guardians.length > 1) ...[
            const SizedBox(height: 32),
            Text('Other Guardians', style: AppTextStyles.heading4),
            const SizedBox(height: 16),
            ...guardians
                .skip(1)
                .map((g) => _AdditionalGuardianCard(guardian: g)),
          ],
        ],
      ),
    );
  }
}

class _AdditionalGuardianCard extends StatelessWidget {
  const _AdditionalGuardianCard({required this.guardian});

  final GuardianModel guardian;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                guardian.fullName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  guardian.relation ?? 'Guardian',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (guardian.phone != null && guardian.phone!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  guardian.phone!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (guardian.email != null && guardian.email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    guardian.email!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
