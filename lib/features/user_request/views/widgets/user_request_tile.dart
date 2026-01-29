import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';

enum UserType { student, guardian, employee }

enum ApprovalStatus { approved, pending }

class UserRequestTile extends StatelessWidget {
  const UserRequestTile({
    super.key,
    this.name = 'Priya',
    this.className = '8 A',
    this.userId = '64452',
    this.date = '10/01/2025',
    this.userType = UserType.student,
    this.status = ApprovalStatus.approved,
    this.imageUrl,
    this.onApprove,
  });

  final String name;
  final String className;
  final String userId;
  final String date;
  final UserType userType;
  final ApprovalStatus status;
  final String? imageUrl;
  final VoidCallback? onApprove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          date,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          className,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 18,
                          child: VerticalDivider(color: AppColors.border),
                        ),
                        Text(
                          'ID $userId',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary.withAlpha(160),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: AppColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildUserTypeChip(), _buildStatusChip()],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.border.withAlpha(50),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              Icons.person,
              size: 32,
              color: AppColors.textPrimary.withAlpha(160),
            )
          : null,
    );
  }

  Widget _buildUserTypeChip() {
    final (color, label) = switch (userType) {
      UserType.student => (AppColors.primary, 'Student'),
      UserType.guardian => (AppColors.orange, 'Guardian'),
      UserType.employee => (const Color(0xFF8B5CF6), 'Employee'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final isApproved = status == ApprovalStatus.approved;
    final color = isApproved ? AppColors.green : AppColors.orange;
    final label = isApproved ? 'Approved' : 'Approve';

    return GestureDetector(
      onTap: isApproved ? null : onApprove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }
}
