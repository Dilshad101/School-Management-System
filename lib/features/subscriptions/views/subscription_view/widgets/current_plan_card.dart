import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_management_system/features/subscriptions/blocs/subscription/subscription_state.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// Card showing the current subscription details.
class CurrentPlanCard extends StatelessWidget {
  const CurrentPlanCard({
    super.key,
    required this.subscription,
    required this.onRenewPressed,
    this.isLoading = false,
  });

  final CurrentSubscriptionModel subscription;
  final VoidCallback onRenewPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name and Renew button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subscription.planName, style: AppTextStyles.heading4),
              _RenewButton(
                onPressed: isLoading ? null : onRenewPressed,
                isLoading: isLoading,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Price, duration and status
          Row(
            children: [
              Text(
                subscription.formattedPrice,
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                ' / ${subscription.durationText}',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(width: 12),
              _StatusBadge(status: subscription.status),
            ],
          ),
          const SizedBox(height: 4),

          // Renews on date
          Text(
            'Renews On: ${DateFormat('dd MMMM yyyy').format(subscription.renewsOn)}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),

          // Storage section
          const Text('Storage Used', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),

          // Storage progress bar
          _StorageProgressBar(
            used: subscription.storageUsed,
            total: subscription.totalStorage,
          ),
          const SizedBox(height: 4),

          // Storage text
          Text(subscription.storageText, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Renew Plan button.
class _RenewButton extends StatelessWidget {
  const _RenewButton({required this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Renew Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Status badge for subscription.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SubscriptionStatus status;

  Color get _backgroundColor {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.green.withAlpha(30);
      case SubscriptionStatus.expired:
        return Colors.red.withAlpha(30);
      case SubscriptionStatus.cancelled:
        return Colors.orange.withAlpha(30);
    }
  }

  Color get _textColor {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.green;
      case SubscriptionStatus.expired:
        return Colors.red;
      case SubscriptionStatus.cancelled:
        return Colors.orange;
    }
  }

  String get _text {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _text,
        style: TextStyle(
          color: _textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Storage progress bar with gradient.
class _StorageProgressBar extends StatelessWidget {
  const _StorageProgressBar({required this.used, required this.total});

  final double used;
  final double total;

  @override
  Widget build(BuildContext context) {
    final percentage = (used / total).clamp(0.0, 1.0);

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
