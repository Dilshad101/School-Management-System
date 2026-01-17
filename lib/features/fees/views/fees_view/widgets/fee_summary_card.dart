import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';

class FeeSummaryCard extends StatelessWidget {
  const FeeSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.percentageChange,
    this.isPositive = true,
  });

  final String label;
  final String value;
  final String? percentageChange;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(fontWeight: FontWeight.bold),
          ),
          if (percentageChange != null) ...[
            const SizedBox(height: 2),
            Text(
              percentageChange!,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10,
                color: isPositive ? AppColors.green : Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
