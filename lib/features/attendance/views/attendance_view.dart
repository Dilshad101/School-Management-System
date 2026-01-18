import 'package:flutter/material.dart';

import '../../../shared/styles/app_styles.dart';
import '../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../shared/widgets/input_fields/search_field.dart';
import 'widgets/attendance_tile.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final List<Map<String, dynamic>> attendanceData = [
    {
      'name': 'Priya',
      'class': '8 A',
      'id': 'ID 64452',
      'date': '10/01/2025',
      'timeIn': '09:05 AM',
      'timeOut': '04:00 PM',
      'status': AttendanceStatus.present,
    },
    {
      'name': 'Priya',
      'class': '8 A',
      'id': 'ID 64452',
      'date': '10/01/2025',
      'timeIn': null,
      'timeOut': null,
      'status': AttendanceStatus.absent,
    },
    {
      'name': 'Priya',
      'class': '8 A',
      'id': 'ID 64452',
      'date': '10/01/2025',
      'timeIn': '09:05 AM',
      'timeOut': '04:00 AM',
      'status': AttendanceStatus.present,
    },
    {
      'name': 'Priya',
      'class': '8 A',
      'id': 'ID 64452',
      'date': '10/01/2025',
      'timeIn': '09:05 AM',
      'timeOut': '04:00 PM',
      'status': AttendanceStatus.present,
    },
  ];

  final _classes = const ['Class 1', 'Class 2', 'Class 3'];
  final _divisions = const ['Division A', 'Division B', 'Division C'];
  final _students = ['Priya', 'Aarav', 'Saanvi'];
  String? _selectedClass;
  String? _selectedDivision;
  String? _selectedStudent;

  late ValueNotifier<bool> _allSelectedNotifier;

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search bar with filter button
            Row(
              children: [
                Expanded(child: AppSearchBar(onChanged: (value) {})),
                const SizedBox(width: 8),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.primaryGradient,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () {
                      // Handle filter action
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Filter and sort options
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder(
                valueListenable: _allSelectedNotifier,
                builder: (context, value, child) {
                  return Row(
                    spacing: 8,
                    children: [
                      _buildAllChip(value),
                      FilterDropdown<String>(
                        items: _students,
                        value: _selectedStudent,
                        onChanged: (value) {
                          print('student - $value');
                          if (value == null) return;
                          _selectedStudent = value;
                          _allSelectedNotifier.value = false;
                        },
                        hintText: 'Student',
                      ),
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
            ),
            const SizedBox(height: 16),
            // Attendance list
            Expanded(
              child: ListView.separated(
                itemCount: attendanceData.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final data = attendanceData[index];
                  return AttendanceTile(
                    studentName: data['name'],
                    className: data['class'],
                    studentId: data['id'],
                    date: data['date'],
                    timeIn: data['timeIn'],
                    timeOut: data['timeOut'],
                    status: data['status'],
                  );
                },
              ),
            ),
          ],
        ),
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
