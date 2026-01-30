import 'package:flutter/material.dart';
import 'package:school_management_system/features/subscriptions/blocs/subscription/subscription_state.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// Toggle between Monthly and Yearly billing.
class BillingToggle extends StatelessWidget {
  const BillingToggle({
    super.key,
    required this.selectedBillingType,
    required this.onChanged,
  });

  final BillingType selectedBillingType;
  final ValueChanged<BillingType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: 'Monthly',
            isSelected: selectedBillingType == BillingType.monthly,
            onTap: () => onChanged(BillingType.monthly),
          ),
          _ToggleButton(
            label: 'Yearly',
            isSelected: selectedBillingType == BillingType.yearly,
            onTap: () => onChanged(BillingType.yearly),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          gradient: isSelected ? AppColors.primaryGradient : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
