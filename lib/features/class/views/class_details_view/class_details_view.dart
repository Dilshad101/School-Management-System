import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/di.dart';
import '../../../../shared/styles/app_styles.dart';
import '../../blocs/class_details/class_details_cubit.dart';
import '../../blocs/class_details/class_details_state.dart';
import '../../repositories/classroom_repository.dart';
import 'tabs/students_tab.dart';
import 'tabs/time_table_tab.dart';
import 'widgets/class_detail_info_card.dart';

class ClassDetailsView extends StatelessWidget {
  const ClassDetailsView({super.key, required this.classId});
  final String? classId;

  @override
  Widget build(BuildContext context) {
    if (classId == null || classId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Class Details')),
        body: const Center(child: Text('Invalid class ID')),
      );
    }

    return BlocProvider(
      create: (context) =>
          ClassDetailsCubit(classroomRepository: locator<ClassroomRepository>())
            ..fetchClassroomDetails(classId!),
      child: _ClassDetailsContent(classId: classId!),
    );
  }
}

class _ClassDetailsContent extends StatefulWidget {
  const _ClassDetailsContent({required this.classId});

  final String classId;

  @override
  State<_ClassDetailsContent> createState() => _ClassDetailsContentState();
}

class _ClassDetailsContentState extends State<_ClassDetailsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Details')),
      body: BlocBuilder<ClassDetailsCubit, ClassDetailsState>(
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
                    'Failed to load class details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.borderError,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ClassDetailsCubit>()
                        .fetchClassroomDetails(widget.classId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final classroom = state.classroom;
          if (classroom == null) {
            return const Center(child: Text('No data available'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header info cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClassDetailInfoCard(
                        label: 'Class Teacher',
                        value:
                            classroom.classTeacherDetails?.name ??
                            'Not Assigned',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClassDetailInfoCard(
                        label: 'Total Students',
                        value: '${classroom.studentCount}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClassDetailInfoCard(
                        label: 'Class Name',
                        value: classroom.name,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClassDetailInfoCard(
                        label: 'Academic Year',
                        value: classroom.academicYearDetails?.name ?? '---',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tab Bar with gradient selected indicator
                Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),

                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Students'),
                      Tab(text: 'Timetable'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Students tab
                      ClassStudentsTabView(
                        classroomId: widget.classId,
                      ), // Timetable tab
                      ClassTimetableTabView(
                        classroomId: widget.classId,
                        academicYearId: classroom.academicYear,
                        schoolId: classroom.school,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
