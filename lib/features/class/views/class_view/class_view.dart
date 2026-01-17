import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../../shared/widgets/input_fields/search_field.dart';
import 'widgets/class_tile.dart';

class ClassView extends StatelessWidget {
  const ClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classes')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search bar
            AppSearchBar(onChanged: (value) {}),
            const SizedBox(height: 10),

            // filter and sort options
            Row(
              spacing: 8,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border.withAlpha(180)),
                  ),
                  child: Text('All', style: AppTextStyles.bodySmall),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    spacing: 5,
                    children: [
                      Text('Class', style: AppTextStyles.bodySmall),
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    spacing: 5,
                    children: [
                      Text('Division', style: AppTextStyles.bodySmall),
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Class list
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  // Show different states based on index for demonstration
                  if (index == 1) {
                    return ClassTile(
                      className: 'Class 10 - A',
                      roomNumber: 'Room A-12',
                      teacherName: 'Ms. johnson',
                      studentCount: 36,
                      subjectCount: 8,
                      hasTimetable: false,
                      daysLeft: 2,
                    );
                  }
                  return ClassTile(
                    className: 'Class 10 - A',
                    roomNumber: 'Room A-12',
                    teacherName: 'Ms. johnson',
                    studentCount: 36,
                    subjectCount: 8,
                    onManageTimetable: () {
                      // Handle manage timetable
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: () {}),
    );
  }
}
