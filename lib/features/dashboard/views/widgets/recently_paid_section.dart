import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../models/dashboard_models.dart';

/// Section for recently paid fees on dashboard.
class RecentlyPaidSection extends StatelessWidget {
  const RecentlyPaidSection({
    super.key,
    required this.payments,
    this.isLoading = false,
    this.onViewAll,
  });

  final List<RecentlyPaidFee> payments;
  final bool isLoading;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently paid',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Content
        if (isLoading)
          _buildLoadingState()
        else if (payments.isEmpty)
          _buildEmptyState()
        else
          _buildPaymentsList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < 1 ? 12 : 0),
          child: _RecentlyPaidTileShimmer(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment_outlined,
            size: 48,
            color: AppColors.textSecondary.withAlpha(100),
          ),
          const SizedBox(height: 8),
          Text(
            'No recent payments',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList() {
    return Column(
      children: payments.map((payment) {
        final isLast = payment == payments.last;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: RecentlyPaidTile(payment: payment),
        );
      }).toList(),
    );
  }
}

/// Individual recently paid fee tile.
class RecentlyPaidTile extends StatelessWidget {
  const RecentlyPaidTile({super.key, required this.payment, this.onTap});

  final RecentlyPaidFee payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name and payment method
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.studentName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          payment.className,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 12,
                          color: AppColors.border,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          payment.studentId,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Payment method badge
                _PaymentMethodBadge(method: payment.paymentMethod),
              ],
            ),
            const SizedBox(height: 16),
            // Fee breakdown row
            Row(
              children: [
                _FeeColumn(
                  label: 'TOTAL FEES',
                  value: payment.formattedTotalFees,
                ),
                const SizedBox(width: 24),
                _FeeColumn(label: 'PAID', value: payment.formattedPaidAmount),
                const SizedBox(width: 24),
                _FeeColumn(
                  label: 'DUE',
                  value: payment.formattedDueAmount,
                  valueColor: payment.dueAmount > 0
                      ? AppColors.borderError
                      : AppColors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment method badge.
class _PaymentMethodBadge extends StatelessWidget {
  const _PaymentMethodBadge({required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String get _label {
    switch (method) {
      case PaymentMethod.bank:
        return 'Bank';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
    }
  }

  Color get _backgroundColor {
    switch (method) {
      case PaymentMethod.bank:
        return AppColors.primary.withAlpha(20);
      case PaymentMethod.cash:
        return AppColors.green.withAlpha(20);
      case PaymentMethod.upi:
        return Colors.purple.withAlpha(20);
      case PaymentMethod.card:
        return Colors.orange.withAlpha(20);
    }
  }

  Color get _textColor {
    switch (method) {
      case PaymentMethod.bank:
        return AppColors.primary;
      case PaymentMethod.cash:
        return AppColors.green;
      case PaymentMethod.upi:
        return Colors.purple;
      case PaymentMethod.card:
        return Colors.orange;
    }
  }
}

/// Fee column with label and value.
class _FeeColumn extends StatelessWidget {
  const _FeeColumn({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

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
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading state for recently paid tile.
class _RecentlyPaidTileShimmer extends StatelessWidget {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.border.withAlpha(100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.border.withAlpha(100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              Container(
                width: 50,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.border.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fee breakdown row
          Row(
            children: [
              _buildShimmerColumn(),
              const SizedBox(width: 24),
              _buildShimmerColumn(),
              const SizedBox(width: 24),
              _buildShimmerColumn(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.border.withAlpha(100),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 50,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.border.withAlpha(100),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
