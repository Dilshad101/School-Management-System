import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/styles/app_styles.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.iconPath,
    this.percentageChange,
    this.isPositive = true,
  });

  final String label;
  final String value;
  final String iconPath;
  final String? percentageChange;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withAlpha(60),
                  AppColors.primary.withAlpha(60),
                ],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(iconPath),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: AppTextStyles.heading4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (percentageChange != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    percentageChange!,
                    style: AppTextStyles.small.copyWith(
                      color: isPositive ? AppColors.green : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
