import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/core/utils/helpers.dart';
import 'package:school_management_system/features/students/views/students_view/widgets/student_tile.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/floating_action_button.dart';

import '../../../../core/utils/di.dart';
import '../../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../../shared/widgets/input_fields/search_field.dart';
import '../../blocs/students/students_bloc.dart';
import '../../blocs/students/students_event.dart';
import '../../blocs/students/students_state.dart';
import '../../repositories/students_repository.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StudentsBloc(studentsRepository: locator<StudentsRepository>())
            ..add(const StudentsFetchRequested()),
      child: const _StudentsViewContent(),
    );
  }
}

class _StudentsViewContent extends StatefulWidget {
  const _StudentsViewContent();

  @override
  State<_StudentsViewContent> createState() => _StudentsViewContentState();
}

class _StudentsViewContentState extends State<_StudentsViewContent> {
  final _classes = const ['Class 1', 'Class 2', 'Class 3'];
  final _divisions = const ['Division A', 'Division B', 'Division C'];

  String? _selectedClass;
  String? _selectedDivision;

  late ValueNotifier<bool> _allSelectedNotifier;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedClass = _classes.isEmpty ? null : _classes.first;
    _selectedDivision = _divisions.isEmpty ? null : _divisions.first;
    _allSelectedNotifier = ValueNotifier<bool>(true);
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _allSelectedNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<StudentsBloc>().add(const StudentsLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    context.read<StudentsBloc>().add(StudentsSearchRequested(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search bar with filter button
            AppSearchBar(onChanged: _onSearchChanged),
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
            // Students list
            Expanded(
              child: BlocConsumer<StudentsBloc, StudentsState>(
                listenWhen: (previous, current) =>
                    previous.error != current.error && current.error != null,
                listener: (context, state) {
                  if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error!),
                        backgroundColor: AppColors.borderError,
                      ),
                    );
                    context.read<StudentsBloc>().add(
                      const StudentsErrorCleared(),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.isDeleting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${state.error}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.borderError,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<StudentsBloc>().add(
                                const StudentsFetchRequested(refresh: true),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.isSearching
                                ? 'No students found for "${state.searchQuery}"'
                                : 'No students found',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<StudentsBloc>().add(
                        StudentsFetchRequested(
                          refresh: true,
                          search: state.searchQuery.isNotEmpty
                              ? state.searchQuery
                              : null,
                        ),
                      );
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount:
                          state.students.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index >= state.students.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final student = state.students[index];
                        return StudentTile(
                          student: student,
                          onEdit: () {
                            context.push(
                              Routes.createStudent,
                              extra: student.id,
                            );
                          },
                          onDelete: () {
                            Helpers.showWarningBottomSheet(
                              context,
                              title: 'Delete Student',
                              message:
                                  'Are you sure you want to delete this student?',
                              onConfirm: () {
                                context.read<StudentsBloc>().add(
                                  StudentDeleteRequested(
                                    studentId: student.id!,
                                  ),
                                );
                              },
                              confirmText: 'Delete',
                            );
                          },
                        );
                      },
                    ),
                  );
                },
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
        context.read<StudentsBloc>().add(const StudentsSearchCleared());
      },
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
          'All',
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
