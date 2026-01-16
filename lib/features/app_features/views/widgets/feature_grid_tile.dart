import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/styles/app_styles.dart';

class FeatureGridTile extends StatelessWidget {
  const FeatureGridTile({super.key, required this.feature});

  final FeatureData feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient.withOpacity(0.3),
            ),
            child: SvgPicture.asset(feature.iconPath),
          ),
          Text(feature.name, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class FeatureData {
  final String name;
  final String iconPath;

  FeatureData({required this.name, required this.iconPath});
}
