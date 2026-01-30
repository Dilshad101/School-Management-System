import 'package:flutter/material.dart';
import 'package:school_management_system/features/subscriptions/blocs/subscription/subscription_state.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';
import 'package:school_management_system/shared/widgets/text/gradiant_text.dart';

/// Card showing a subscription plan with features.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.billingType,
    required this.onUpgradePressed,
    this.isLoading = false,
  });

  final SubscriptionPlanModel plan;
  final BillingType billingType;
  final VoidCallback? onUpgradePressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final price = plan.getPrice(billingType);
    final duration = billingType == BillingType.monthly ? '3 month' : '1 year';
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.65,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: plan.isCurrentPlan
            ? Border.all(color: AppColors.primary, width: 1.2)
            : Border.all(color: AppColors.border, width: 1),
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
          // Plan name
          Text(plan.name, style: AppTextStyles.heading4),
          const SizedBox(height: 8),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(' / $duration', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            plan.description,
            style: AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Features list
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plan.features.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final feature = plan.features[index];
                return _FeatureItem(feature: feature);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Upgrade/Current button
          if (plan.isCurrentPlan)
            _CurrentPlanButton()
          else
            GradientButton(
              label: 'Upgrade to Premium',
              height: 44,
              isLoading: isLoading,
              onPressed: onUpgradePressed,
            ),
        ],
      ),
    );
  }
}

/// Feature item with check/dash icon.
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.feature});

  final FeatureModel feature;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          feature.isIncluded ? Icons.check_circle : Icons.remove_circle,
          size: 18,
          color: feature.isIncluded ? AppColors.green : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            feature.name,
            style: AppTextStyles.bodySmall.copyWith(
              color: feature.isIncluded
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Button showing current plan status.
class _CurrentPlanButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: const Center(
        child: GradientText(
          'Current Plan',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
