import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/styles/app_styles.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    this.requestCount = 84,
    this.onRequestTap,
    this.onNotificationTap,
  });

  final int requestCount;
  final VoidCallback? onRequestTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      decoration: const BoxDecoration(
        // gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and welcome text
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logo_v2.svg',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EduFlow',
                        style: AppTextStyles.heading4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          'Admin, welcome back',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Request and notification
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onRequestTap,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/person_alt_white.svg'),
                    const SizedBox(width: 4),
                    Text(
                      'Request ($requestCount)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/notification.svg',
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
