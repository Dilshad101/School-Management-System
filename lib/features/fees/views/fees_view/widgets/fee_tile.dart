import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../models/student_fee_model.dart';

class FeeTile extends StatelessWidget {
  const FeeTile({super.key, required this.fee, this.onTap, this.onAddPayment});

  final StudentFeeModel fee;
  final VoidCallback? onTap;
  final VoidCallback? onAddPayment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fee.studentName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Class: ${fee.classroomName}',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildStatusBadge(),
                    const SizedBox(width: 8),
                    // Payment button
                    _PaymentButton(onTap: onAddPayment),
                  ],
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 24),
            // Fee breakdown row
            Row(
              children: [
                Expanded(
                  child: _buildFeeInfo(
                    label: 'TOTAL FEES',
                    value: fee.formattedTotalFee,
                    valueColor: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: _buildFeeInfo(
                    label: 'PAID',
                    value: fee.formattedPaidFee,
                    valueColor: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: _buildFeeInfo(
                    label: 'DUE',
                    value: fee.formattedDues,
                    valueColor: fee.status == FeeStatus.paid
                        ? AppColors.textPrimary
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (fee.status) {
      case FeeStatus.paid:
        backgroundColor = AppColors.green.withAlpha(40);
        textColor = AppColors.green;
        text = 'Paid';
        break;
      case FeeStatus.partial:
        backgroundColor = Colors.orange.withAlpha(20);
        textColor = Colors.orange;
        text = 'Partial';
        break;
      case FeeStatus.unpaid:
        backgroundColor = Colors.red.withAlpha(20);
        textColor = Colors.red;
        text = 'Unpaid';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildFeeInfo({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _PaymentButton extends StatelessWidget {
  const _PaymentButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add_card_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}
