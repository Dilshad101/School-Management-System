import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/auth/permissions.dart';
import 'package:school_management_system/core/router/app_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/core/utils/di.dart';
import 'package:school_management_system/features/auth/blocs/user/user_bloc.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

import 'widgets/feature_grid_tile.dart';

class FeaturesPage extends StatelessWidget {
  FeaturesPage({super.key});

  final _features = [
    FeatureData(
      name: 'Employee',
      iconPath: 'assets/icons/employee.svg',
      permission: Permissions.viewUser,
      onTap: () {
        final ctx = locator<NavigationService>().navigatorKey.currentContext;
        if (ctx != null) {
          ctx.push(Routes.employees);
        }
      },
    ),
    FeatureData(
      name: 'Class',
      iconPath: 'assets/icons/class.svg',
      permission: Permissions.viewClassroom,
      onTap: () {
        final ctx = locator<NavigationService>().navigatorKey.currentContext;
        if (ctx != null) {
          ctx.push(Routes.classes);
        }
      },
    ),
    FeatureData(
      name: 'Students',
      iconPath: 'assets/icons/students.svg',
      permission: Permissions.viewStudent,
      onTap: () {
        final ctx = locator<NavigationService>().navigatorKey.currentContext;
        if (ctx != null) {
          ctx.push(Routes.students);
        }
      },
    ),
    FeatureData(
      name: 'Guardian',
      iconPath: 'assets/icons/guardian.svg',
      permission: Permissions.viewGuardian,
      onTap: () {
        final ctx = locator<NavigationService>().navigatorKey.currentContext;
        if (ctx != null) {
          ctx.push(Routes.guardians);
        }
      },
    ),
    FeatureData(
      name: 'Attendance',
      iconPath: 'assets/icons/attendance.svg',
      permission: Permissions.viewAttendance,
      onTap: () {
        final ctx = locator<NavigationService>().navigatorKey.currentContext;
        if (ctx != null) {
          ctx.push(Routes.attendance);
        }
      },
    ),
    FeatureData(
      name: 'Manage Fees',
      iconPath: 'assets/icons/fees.svg',
      permission: Permissions.viewFee,
      onTap: () {
        final ctx = locator<NavigationService>().navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          ctx.push(Routes.fees);
        }
      },
    ),
    FeatureData(
      name: 'Notification',
      iconPath: 'assets/icons/notification.svg',
      permission: Permissions.viewNotification,
      onTap: () {
        final ctx = locator<NavigationService>().navigatorKey.currentContext;
        if (ctx != null) {
          ctx.push(Routes.notifications);
        }
      },
    ),
    FeatureData(
      name: 'Subscription',
      iconPath: 'assets/icons/subscription.svg',
      permission: Permissions.viewSubscription,
      onTap: () {
        final ctx = locator<NavigationService>().navigatorKey.currentContext;
        if (ctx != null) {
          ctx.push(Routes.subscriptions);
        }
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  // Filter features based on user permissions
                  final permittedFeatures = _features.where((feature) {
                    if (feature.permission == null) return true;
                    return userState.hasPermission(feature.permission!);
                  }).toList();

                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: permittedFeatures.length,
                    itemBuilder: (context, index) {
                      final feature = permittedFeatures[index];
                      return FeatureGridTile(feature: feature);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
