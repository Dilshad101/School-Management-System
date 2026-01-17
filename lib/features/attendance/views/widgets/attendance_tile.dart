import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';

enum AttendanceStatus { present, absent }

class AttendanceTile extends StatelessWidget {
  const AttendanceTile({
    super.key,
    this.studentName = 'Priya',
    this.className = '8 A',
    this.studentId = 'ID 64452',
    this.date = '10/01/2025',
    this.timeIn,
    this.timeOut,
    this.status = AttendanceStatus.present,
    this.imageUrl,
  });

  final String studentName;
  final String className;
  final String studentId;
  final String date;
  final String? timeIn;
  final String? timeOut;
  final AttendanceStatus status;
  final String? imageUrl;

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
          // Student info row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Profile image
              Container(
                height: 64,
                width: 64,
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
                        size: 32,
                        color: AppColors.textPrimary.withAlpha(160),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              // Name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            studentName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildStatusBadge(),
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
                          studentId,
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
          const Divider(color: AppColors.border, height: 24),
          // Time info row
          Row(
            children: [
              // Date
              Text(
                date,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Time In
              _buildTimeInfo(
                label: 'TIME IN',
                time: timeIn ?? '-/-',
                icon: Icons.login_rounded,
              ),
              const SizedBox(width: 16),
              // Time Out
              _buildTimeInfo(
                label: 'TIME OUT',
                time: timeOut ?? '-/-',
                icon: Icons.logout_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool isPresent = status == AttendanceStatus.present;
    return Container(
      decoration: BoxDecoration(
        color: isPresent
            ? AppColors.green.withAlpha(20)
            : Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        isPresent ? 'Present' : 'Absent',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          color: isPresent ? AppColors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required String label,
    required String time,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
            Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
