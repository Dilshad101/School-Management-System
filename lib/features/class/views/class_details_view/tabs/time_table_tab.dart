import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';

class ClassTimetableTabView extends StatefulWidget {
  const ClassTimetableTabView({super.key});

  @override
  State<ClassTimetableTabView> createState() => _ClassTimetableTabViewState();
}

class _ClassTimetableTabViewState extends State<ClassTimetableTabView> {
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  int _currentDayIndex = 0;

  // Sample timetable data
  final List<Map<String, String>> _timetableData = [
    {'period': '1', 'subject': 'English', 'teacher': 'Mr. Smith'},
    {'period': '2', 'subject': 'English', 'teacher': 'Mr. Smith'},
    {'period': '3', 'subject': 'English', 'teacher': 'Mr. Smith'},
    {'period': '4', 'subject': 'English', 'teacher': 'Mr. Smith'},
    {'period': '5', 'subject': 'English', 'teacher': 'Mr. Smith'},
    {'period': '6', 'subject': 'English', 'teacher': 'Mr. Smith'},
    {'period': '7', 'subject': 'English', 'teacher': 'Mr. Smith'},
  ];

  void _previousDay() {
    if (_currentDayIndex > 0) {
      setState(() {
        _currentDayIndex--;
      });
    }
  }

  void _nextDay() {
    if (_currentDayIndex < _days.length - 1) {
      setState(() {
        _currentDayIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Day header with navigation
                _buildDayHeader(),
                const SizedBox(height: 16),
                // Table header
                _buildTableHeader(),
                const Divider(color: AppColors.border, height: 1),
                // Table rows
                Expanded(
                  child: ListView.separated(
                    itemCount: _timetableData.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppColors.border, height: 1),
                    itemBuilder: (context, index) {
                      final item = _timetableData[index];
                      return _buildTableRow(
                        period: item['period']!,
                        subject: item['subject']!,
                        teacher: item['teacher']!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_days[_currentDayIndex], style: AppTextStyles.heading4),
        Row(
          children: [
            _buildNavigationButton(
              icon: Icons.chevron_left,
              onTap: _currentDayIndex > 0 ? _previousDay : null,
            ),
            const SizedBox(width: 8),
            _buildNavigationButton(
              icon: Icons.chevron_right,
              onTap: _currentDayIndex < _days.length - 1 ? _nextDay : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButton({required IconData icon, VoidCallback? onTap}) {
    final bool isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.border.withAlpha(80),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled
              ? AppColors.textPrimary
              : AppColors.textSecondary.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Periods',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTextStyles.bodySmall.color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Subject',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTextStyles.bodySmall.color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Teacher',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTextStyles.bodySmall.color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required String period,
    required String subject,
    required String teacher,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              period,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              subject,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              teacher,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
