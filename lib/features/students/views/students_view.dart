import 'package:flutter/material.dart';
import 'package:school_management_system/features/students/views/widgets/student_tile.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/floating_action_button.dart';

import '../../../shared/widgets/input_fields/search_field.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Students')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search bar with filter button
            Row(
              spacing: 8,
              children: [
                Expanded(child: AppSearchBar(onChanged: (value) {})),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.primaryGradient,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.tune, color: Colors.white),
                    onPressed: () {
                      // Handle filter action
                    },
                  ),
                ),
              ],
            ),
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
            // Employee list placeholder
            // EmployeeTile(),
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemBuilder: (context, index) => StudentTile(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: () {}),
    );
  }
}
