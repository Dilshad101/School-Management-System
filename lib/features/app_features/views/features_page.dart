import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

import 'widgets/feature_grid_tile.dart';

class FeaturesPage extends StatelessWidget {
  FeaturesPage({super.key});

  final _features = [
    FeatureData(name: 'Employee', iconPath: 'assets/icons/employee.svg'),
    FeatureData(name: 'Class', iconPath: 'assets/icons/class.svg'),
    FeatureData(name: 'Students', iconPath: 'assets/icons/students.svg'),
    FeatureData(name: 'Guardian', iconPath: 'assets/icons/guardian.svg'),
    FeatureData(name: 'Attendance', iconPath: 'assets/icons/attendance.svg'),
    FeatureData(name: 'Manage Fees', iconPath: 'assets/icons/fees.svg'),
    FeatureData(
      name: 'Notification',
      iconPath: 'assets/icons/notification.svg',
    ),
    FeatureData(name: 'Chat', iconPath: 'assets/icons/chat_feature.svg'),
    FeatureData(
      name: 'Subscription',
      iconPath: 'assets/icons/subscription.svg',
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
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  final feature = _features[index];
                  return FeatureGridTile(feature: feature);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
