import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/features/students/views/students_view/widgets/student_tile.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/floating_action_button.dart';

import '../../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../../shared/widgets/input_fields/search_field.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final _classes = const ['Class 1', 'Class 2', 'Class 3'];
  final _divisions = const ['Division A', 'Division B', 'Division C'];

  String? _selectedClass;
  String? _selectedDivision;

  late ValueNotifier<bool> _allSelectedNotifier;

  @override
  void initState() {
    super.initState();
    _selectedClass = _classes.isEmpty ? null : _classes.first;
    _selectedDivision = _divisions.isEmpty ? null : _divisions.first;
    _allSelectedNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _allSelectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Students')),
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
                      items: _classes,
                      value: _selectedClass,
                      onChanged: (value) {
                        print('class - $value');
                        if (value == null) return;
                        _selectedClass = value;
                        _allSelectedNotifier.value = false;
                      },
                      hintText: 'Class',
                    ),
                    FilterDropdown<String>(
                      items: _divisions,
                      value: _selectedDivision,
                      onChanged: (value) {
                        print('division - $value');
                        if (value == null) return;
                        _selectedDivision = value;
                        _allSelectedNotifier.value = false;
                      },
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
                itemBuilder: (context, index) => StudentTile(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: MyFloatingActionButton(
        onPressed: () {
          context.push(Routes.createStudent);
        },
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
