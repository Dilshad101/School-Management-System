import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// A step indicator widget that shows progress through a multi-step form.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: 80,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: (isActive) ? AppColors.primaryGradient : null,
            color: (isActive) ? null : AppColors.border.withAlpha(150),
          ),
        );
      }),
    );
  }
}
