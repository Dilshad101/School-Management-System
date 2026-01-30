import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/floating_action_button.dart';

import '../../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../../shared/widgets/input_fields/search_field.dart';
import '../../blocs/create_employee/create_employee_state.dart';
import 'widgets/employe_tile.dart';
import 'widgets/staff_category_selector_dialog.dart';

class EmployeesView extends StatefulWidget {
  const EmployeesView({super.key});

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {
  final _roles = const ['Admin', 'Employee', 'Manager'];
  final _subjects = const ['Math', 'Science', 'History', 'Art'];
  String? _selectedRole;
  String? _selectedSubject;

  late ValueNotifier<bool> _allSelectedNotifier;

  // Sample staff categories for the bottom sheet
  final List<StaffCategoryModel> _staffCategories = [
    const StaffCategoryModel(id: '1', name: 'Teachers'),
    const StaffCategoryModel(id: '2', name: 'Office Staff'),
    const StaffCategoryModel(id: '3', name: 'Hostel Warden'),
    const StaffCategoryModel(id: '4', name: 'Security Staff'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = _roles.isNotEmpty ? _roles.first : null;
    _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
    _allSelectedNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _allSelectedNotifier.dispose();
    super.dispose();
  }

  void _showStaffCategorySelector() {
    StaffCategorySelectorDialog.show(
      context: context,
      categories: _staffCategories,
      onCategorySelected: (category) {
        // Navigate to create employee view with pre-selected category
        context.push(Routes.createEmployee, extra: category);
      },
      onAddCategory: (name) {
        // Add the new category to the list
        _staffCategories.add(
          StaffCategoryModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            isCustom: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employees')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search bar with filter button
            AppSearchBar(onChanged: (value) {}),
            const SizedBox(height: 10),

            // filter and sort options
            ValueListenableBuilder(
              valueListenable: _allSelectedNotifier,
              builder: (context, value, child) {
                return Row(
                  spacing: 8,
                  children: [
                    _buildAllChip(value),
                    FilterDropdown<String>(
                      items: _roles,
                      value: _selectedRole,
                      onChanged: (value) {
                        print('role - $value');
                        if (value == null) return;
                        _selectedRole = value;
                        _allSelectedNotifier.value = false;
                      },
                      hintText: 'Employees',
                    ),
                    FilterDropdown<String>(
                      items: _subjects,
                      value: _selectedSubject,
                      onChanged: (value) {
                        print('subject - $value');
                        if (value == null) return;
                        _selectedSubject = value;
                        _allSelectedNotifier.value = false;
                      },
                      hintText: 'Class',
                    ),
                    FilterDropdown<String>(
                      items: const ['Division A', 'Division B', 'Division C'],
                      value: null,
                      onChanged: (value) {},
                      hintText: 'Division',
                    ),
                  ],
                );
              },
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
      floatingActionButton: MyFloatingActionButton(
        onPressed: _showStaffCategorySelector,
      ),
    );
  }

  Widget _buildAllChip(bool isSelected) {
    return InkWell(
      onTap: () {
        _allSelectedNotifier.value = true;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border.withAlpha(180)),
        ),
        child: Text(
          'All',
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
