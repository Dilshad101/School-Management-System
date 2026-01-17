import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';

enum FeeStatus { paid, partial, unpaid }

class FeeTile extends StatelessWidget {
  const FeeTile({
    super.key,
    this.studentName = 'Priya',
    this.className = '8 A',
    this.studentId = 'ID 64452',
    this.totalFees = '₹1,200',
    this.paidAmount = '₹1,200',
    this.dueAmount = '₹0',
    this.status = FeeStatus.paid,
    this.onViewPressed,
    this.onPrintPressed,
    this.onAddPaymentPressed,
  });

  final String studentName;
  final String className;
  final String studentId;
  final String totalFees;
  final String paidAmount;
  final String dueAmount;
  final FeeStatus status;
  final VoidCallback? onViewPressed;
  final VoidCallback? onPrintPressed;
  final VoidCallback? onAddPaymentPressed;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    const SizedBox(height: 2),
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
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          // Fee breakdown row
          Row(
            children: [
              Expanded(
                child: _buildFeeInfo(
                  label: 'TOTAL FEES',
                  value: totalFees,
                  valueColor: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _buildFeeInfo(
                  label: 'PAID',
                  value: paidAmount,
                  valueColor: AppColors.green,
                ),
              ),
              Expanded(
                child: _buildFeeInfo(
                  label: 'DUE',
                  value: dueAmount,
                  valueColor: status == FeeStatus.paid
                      ? AppColors.textPrimary
                      : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 0),
          // Action buttons row
          Row(
            children: [
              // View button
              IconButton(
                onPressed: onViewPressed,
                icon: Icon(
                  Icons.visibility,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // const SizedBox(width: 12),
              // Print button
              IconButton(
                onPressed: onPrintPressed,
                icon: Icon(
                  Icons.print,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // Add Payment button
              TextButton.icon(
                onPressed: onAddPaymentPressed,
                icon: Icon(Icons.add, size: 18, color: AppColors.textPrimary),
                label: Text(
                  'Add Payment',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
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
