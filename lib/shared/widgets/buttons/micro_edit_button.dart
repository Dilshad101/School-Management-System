import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../styles/app_styles.dart';

class MicroEditButton extends StatelessWidget {
  const MicroEditButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withAlpha(5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Icon(
          //   Icons.mode_edit_outlined,
          //   // size: 16,
          //   color: AppColors.green,
          // ),
          SvgPicture.asset('assets/icons/edit.svg'),
          const SizedBox(width: 6),
          Text(
            'Edit',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.green),
          ),
        ],
      ),
    );
  }
}
