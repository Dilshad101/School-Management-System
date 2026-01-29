import 'package:flutter/material.dart';
import 'package:school_management_system/features/user_request/views/widgets/user_request_tile.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/input_fields/search_field.dart';

enum UserRequestFilter { all, students, employee, guardian }

class UserRequestView extends StatefulWidget {
  const UserRequestView({super.key});

  @override
  State<UserRequestView> createState() => _UserRequestViewState();
}

class _UserRequestViewState extends State<UserRequestView> {
  late ValueNotifier<UserRequestFilter> _selectedFilterNotifier;

  @override
  void initState() {
    super.initState();
    _selectedFilterNotifier = ValueNotifier<UserRequestFilter>(
      UserRequestFilter.all,
    );
  }

  @override
  void dispose() {
    _selectedFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Requests')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search bar
            AppSearchBar(onChanged: (value) {}),
            const SizedBox(height: 16),

            // Filter tabs
            ValueListenableBuilder<UserRequestFilter>(
              valueListenable: _selectedFilterNotifier,
              builder: (context, selectedFilter, child) {
                return Row(
                  children: [
                    _buildFilterChip(
                      label: 'All',
                      filter: UserRequestFilter.all,
                      isSelected: selectedFilter == UserRequestFilter.all,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: "Student's",
                      filter: UserRequestFilter.students,
                      isSelected: selectedFilter == UserRequestFilter.students,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Employee',
                      filter: UserRequestFilter.employee,
                      isSelected: selectedFilter == UserRequestFilter.employee,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Guardian',
                      filter: UserRequestFilter.guardian,
                      isSelected: selectedFilter == UserRequestFilter.guardian,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // User request list
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  // Sample data based on index for demonstration
                  final userTypes = [
                    UserType.student,
                    UserType.student,
                    UserType.guardian,
                    UserType.employee,
                    UserType.student,
                  ];
                  final statuses = [
                    ApprovalStatus.approved,
                    ApprovalStatus.approved,
                    ApprovalStatus.pending,
                    ApprovalStatus.pending,
                    ApprovalStatus.approved,
                  ];

                  return UserRequestTile(
                    userType: userTypes[index],
                    status: statuses[index],
                    onApprove: () {
                      // Handle approve action
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

  Widget _buildFilterChip({
    required String label,
    required UserRequestFilter filter,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        _selectedFilterNotifier.value = filter;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border.withAlpha(180)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
