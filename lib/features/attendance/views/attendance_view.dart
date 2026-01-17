import 'package:flutter/material.dart';

import '../../../shared/styles/app_styles.dart';
import '../../../shared/widgets/input_fields/search_field.dart';
import 'widgets/attendance_tile.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
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
              child: Row(
                children: [
                  _buildFilterChip(label: 'All', isSelected: true),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: "Student's", hasDropdown: true),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: 'Class', hasDropdown: true),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: 'Division', hasDropdown: true),
                ],
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

  Widget _buildFilterChip({
    required String label,
    bool isSelected = false,
    bool hasDropdown = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.border.withAlpha(180))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ],
        ],
      ),
    );
  }
}
