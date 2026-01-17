import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../styles/app_styles.dart';

class MicroDeleteButton extends StatelessWidget {
  const MicroDeleteButton({super.key, this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withAlpha(5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset('assets/icons/delete.svg'),
            const SizedBox(width: 6),
            Text(
              'Delete',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.borderError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
