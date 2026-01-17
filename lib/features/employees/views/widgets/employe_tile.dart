import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/micro_delete_button.dart';
import '../../../../shared/widgets/buttons/micro_edit_button.dart';

class EmployeeTile extends StatelessWidget {
  const EmployeeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.border.withAlpha(50),
                ),
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.textPrimary.withAlpha(160),
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: Text(
                            'Priya',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.green.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          child: Text(
                            '98%',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '8A',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 18,
                          child: VerticalDivider(color: AppColors.border),
                        ),
                        Text(
                          'ID 64452',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary.withAlpha(160),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'English',
                      style: AppTextStyles.bodyMedium.apply(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: AppColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [MicroDeleteButton(), MicroEditButton()],
          ),
        ],
      ),
    );
  }
}
