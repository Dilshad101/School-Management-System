import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// A step indicator widget that shows progress through a multi-step form.
class EmployeeStepIndicator extends StatelessWidget {
  const EmployeeStepIndicator({
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
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: (isActive || isCompleted)
                ? AppColors.primaryGradient
                : null,
            color: (isActive || isCompleted)
                ? null
                : AppColors.border.withAlpha(150),
          ),
        );
      }),
    );
  }
}
