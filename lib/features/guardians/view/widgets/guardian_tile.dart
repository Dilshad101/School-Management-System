import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/micro_delete_button.dart';
import '../../../../shared/widgets/buttons/micro_edit_button.dart';
import '../../models/guardian_model.dart';

class GuardianTile extends StatelessWidget {
  const GuardianTile({
    super.key,
    this.guardian,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final GuardianModel? guardian;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final displayName = guardian?.displayName ?? 'Unknown';
    final phone = guardian?.phone ?? 'N/A';
    final email = guardian?.email ?? 'N/A';
    final relation = guardian?.primaryRelation ?? 'Guardian';
    final linkedCount = guardian?.linkedStudentsCount ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Profile image
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.border.withAlpha(50),
                    image: guardian?.profilePic != null
                        ? DecorationImage(
                            image: NetworkImage(guardian!.profilePic!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: guardian?.profilePic == null
                      ? Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.textPrimary.withAlpha(160),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name and status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: (guardian?.isActive ?? true)
                                  ? AppColors.green.withAlpha(20)
                                  : Colors.red.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            child: Text(
                              (guardian?.isActive ?? true)
                                  ? 'Active'
                                  : 'Inactive',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: (guardian?.isActive ?? true)
                                    ? AppColors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Relation and linked students
                      Row(
                        children: [
                          Text(
                            relation,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                            child: VerticalDivider(color: AppColors.border),
                          ),
                          Text(
                            '$linkedCount Student${linkedCount != 1 ? 's' : ''} linked',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary.withAlpha(160),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Phone
                      Text(
                        'Ph: $phone',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary.withAlpha(160),
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Email
                      Text(
                        'Email: $email',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary.withAlpha(160),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MicroDeleteButton(onTap: onDelete),
                const SizedBox(width: 8),
                MicroEditButton(onTap: onEdit),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
