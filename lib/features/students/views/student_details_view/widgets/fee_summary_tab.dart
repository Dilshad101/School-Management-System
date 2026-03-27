import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../models/fee_details_model.dart';

/// Tab content for displaying fee summary.
class FeeSummaryTab extends StatelessWidget {
  const FeeSummaryTab({super.key, required this.feeDetails});

  final StudentFeeDetailsResponse? feeDetails;

  @override
  Widget build(BuildContext context) {
    if (feeDetails == null || feeDetails!.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No fee records found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fee Summary', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          // Fee payment cards
          ...feeDetails!.payments.map(
            (payment) => _FeePaymentCard(payment: payment),
          ),
          const SizedBox(height: 16),
          // Total summary
          _TotalSummary(summary: feeDetails!.summary),
        ],
      ),
    );
  }
}

class _FeePaymentCard extends StatelessWidget {
  const _FeePaymentCard({required this.payment});

  final FeePaymentModel payment;

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
          // Fee structure name and date
          Text(
            payment.feeStructureName ?? 'Fee',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Date ${payment.formattedDate}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Amount row
          Row(
            children: [
              Expanded(
                child: _AmountColumn(
                  label: 'TOTAL',
                  amount: payment.totalFeeValue,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: 'PAID',
                  amount: payment.totalPaidValue,
                  color: AppColors.green,
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: 'PENDING',
                  amount: payment.pendingValue,
                  color: payment.pendingValue > 0
                      ? AppColors.borderError
                      : AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${_formatAmount(amount)}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}

class _TotalSummary extends StatelessWidget {
  const _TotalSummary({required this.summary});

  final FeeSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: 'Total Paid',
            amount: summary.totalPaid,
            color: AppColors.textPrimary,
          ),
          const Divider(height: 24),
          _TotalRow(
            label: 'Total Due',
            amount: summary.pendingFee,
            color: summary.pendingFee > 0
                ? AppColors.borderError
                : AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '₹${_formatAmount(amount)}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}
