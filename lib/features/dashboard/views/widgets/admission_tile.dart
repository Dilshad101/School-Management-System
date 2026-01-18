import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';

enum AdmissionStatus { pending, approved }

class AdmissionTile extends StatelessWidget {
  const AdmissionTile({
    super.key,
    this.studentName = 'Priya',
    this.className = '8 A',
    this.studentId = 'ID 64452',
    this.status = AdmissionStatus.pending,
    this.imageUrl,
    this.onApproveTap,
  });

  final String studentName;
  final String className;
  final String studentId;
  final AdmissionStatus status;
  final String? imageUrl;
  final VoidCallback? onApproveTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Profile image
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.border.withAlpha(50),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Icon(
                    Icons.person,
                    size: 24,
                    color: AppColors.textPrimary.withAlpha(160),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(className, style: AppTextStyles.bodyMedium),
                    SizedBox(
                      height: 14,
                      child: VerticalDivider(color: AppColors.border),
                    ),
                    Text(
                      studentId,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final bool isPending = status == AdmissionStatus.pending;
    return GestureDetector(
      onTap: isPending ? onApproveTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isPending
              ? Colors.orange.withAlpha(50)
              : AppColors.green.withAlpha(50),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isPending ? 'Approve' : 'Approved',
          style: AppTextStyles.bodySmall.copyWith(
            color: isPending ? AppColors.orange : AppColors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
