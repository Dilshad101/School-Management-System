import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/floating_action_button.dart';

import '../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../shared/widgets/input_fields/search_field.dart';
import 'widgets/employe_tile.dart';

class EmployeesView extends StatefulWidget {
  const EmployeesView({super.key});

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {
  final _roles = const ['All', 'Admin', 'Employee', 'Manager'];
  final _subjects = const ['All', 'Math', 'Science', 'History', 'Art'];
  String _selectedRole = 'Employee';
  String _selectedSubject = 'Math';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employees')),
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
                _buildAllChip(),
                FilterDropdown<String>(
                  items: _roles,
                  value: _selectedRole,
                  onChanged: (value) {
                    if (value == null) return;
                    _selectedRole = value;
                  },
                  hintText: 'Role',
                ),
                FilterDropdown<String>(
                  items: _subjects,
                  value: _selectedSubject,
                  onChanged: (value) {
                    if (value == null) return;
                    _selectedSubject = value;
                  },
                  hintText: 'Subject',
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
                itemBuilder: (context, index) => EmployeeTile(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: () {}),
    );
  }

  Widget _buildAllChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withAlpha(180)),
      ),
      child: Text('All', style: AppTextStyles.bodySmall),
    );
  }
}
