import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/di.dart';
import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../blocs/student_details/student_details_cubit.dart';
import '../../blocs/student_details/student_details_state.dart';
import '../../repositories/students_repository.dart';
import 'widgets/fee_summary_tab.dart';
import 'widgets/guardian_info_tab.dart';
import 'widgets/student_header.dart';
import 'widgets/student_info_tab.dart';

class StudentDetailsView extends StatelessWidget {
  const StudentDetailsView({super.key, required this.studentId});

  final String? studentId;

  @override
  Widget build(BuildContext context) {
    if (studentId == null || studentId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student')),
        body: const Center(child: Text('Invalid student ID')),
      );
    }

    return BlocProvider(
      create: (context) =>
          StudentDetailsCubit(studentsRepository: locator<StudentsRepository>())
            ..fetchStudentDetails(studentId!),
      child: _StudentDetailsContent(studentId: studentId!),
    );
  }
}

class _StudentDetailsContent extends StatelessWidget {
  const _StudentDetailsContent({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student')),
      body: BlocBuilder<StudentDetailsCubit, StudentDetailsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.borderError,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error ?? 'Failed to load student details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.borderError,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<StudentDetailsCubit>()
                        .fetchStudentDetails(studentId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final student = state.student;
          if (student == null) {
            return const Center(child: Text('No data available'));
          }

          return Column(
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StudentHeader(
                  student: student,
                  isEditMode: state.isEditMode,
                  onEdit: () =>
                      context.read<StudentDetailsCubit>().toggleEditMode(),
                  onDelete: () => _showDeleteConfirmation(context),
                  onToggleActive: (value) {
                    // TODO: Implement toggle active
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TabBar(
                  selectedIndex: state.selectedTabIndex,
                  onTabSelected: (index) =>
                      context.read<StudentDetailsCubit>().selectTab(index),
                ),
              ),
              const SizedBox(height: 8),
              // Tab content
              Expanded(child: _buildTabContent(state)),
              // Send Message button
              if (state.isEditMode)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GradientButton(
                    label: 'Sent Message',
                    onPressed: () {
                      // TODO: Implement send message
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabContent(StudentDetailsState state) {
    switch (state.selectedTabIndex) {
      case 0:
        return StudentInfoTab(student: state.student!);
      case 1:
        return GuardianInfoTab(guardians: state.student!.guardians);
      case 2:
        return FeeSummaryTab(feeDetails: state.feeDetails);
      default:
        return StudentInfoTab(student: state.student!);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text(
          'Are you sure you want to delete this student? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.borderError),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selectedIndex, required this.onTabSelected});

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        StudentDetailsState.tabNames.length,
        (index) => Expanded(
          child: _TabItem(
            label: StudentDetailsState.tabNames[index],
            isSelected: selectedIndex == index,
            onTap: () => onTabSelected(index),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border.withAlpha(100)),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
