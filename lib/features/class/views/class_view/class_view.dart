import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/core/utils/di.dart';
import 'package:school_management_system/features/class/blocs/classroom/classroom_bloc.dart';
import 'package:school_management_system/features/class/repositories/classroom_repository.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../../shared/widgets/input_fields/search_field.dart';
import 'widgets/class_tile.dart';

class ClassView extends StatelessWidget {
  const ClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ClassroomBloc(classroomRepository: locator<ClassroomRepository>())
            ..add(const FetchClassrooms()),
      child: const _ClassViewContent(),
    );
  }
}

class _ClassViewContent extends StatefulWidget {
  const _ClassViewContent();

  @override
  State<_ClassViewContent> createState() => _ClassViewContentState();
}

class _ClassViewContentState extends State<_ClassViewContent> {
  final _classes = const ['Class 1', 'Class 2', 'Class 3'];
  final _divisions = const ['Division A', 'Division B', 'Division C'];

  String? _selectedClass;
  String? _selectedDivision;

  late ValueNotifier<bool> _allSelectedNotifier;

  @override
  void initState() {
    super.initState();
    _selectedClass = _classes.isNotEmpty ? _classes.first : null;
    _selectedDivision = _divisions.isNotEmpty ? _divisions.first : null;
    _allSelectedNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _allSelectedNotifier.dispose();
    super.dispose();
  }

  Future<void> _navigateToCreateClass() async {
    final result = await context.push<bool>(Routes.createClass);
    if (result == true && mounted) {
      context.read<ClassroomBloc>().add(const RefreshClassrooms());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classes')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search bar
            AppSearchBar(
              onChanged: (value) {
                context.read<ClassroomBloc>().add(SearchClassrooms(value));
              },
            ),
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

            // Class list
            Expanded(
              child: BlocConsumer<ClassroomBloc, ClassroomState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: Colors.red,
                      ),
                    );
                    context.read<ClassroomBloc>().add(
                      const ClearClassroomError(),
                    );
                  }
                },
                builder: (context, state) {
                  // Loading state
                  if (state.isLoading && state.classrooms.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Empty state
                  if (state.classrooms.isEmpty && !state.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.class_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withAlpha(100),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No classes found',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context.read<ClassroomBloc>().add(
                                const RefreshClassrooms(),
                              );
                            },
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Success state with data
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ClassroomBloc>().add(
                        const RefreshClassrooms(),
                      );
                    },
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200 &&
                            !state.isLoadingMore &&
                            state.hasNext) {
                          context.read<ClassroomBloc>().add(
                            const LoadMoreClassrooms(),
                          );
                        }
                        return false;
                      },
                      child: ListView.separated(
                        itemCount:
                            state.classrooms.length +
                            (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          // Loading more indicator
                          if (index >= state.classrooms.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final classroom = state.classrooms[index];
                          return ClassTile(
                            classroom: classroom,
                            onManageTimetable: () {
                              context.push(Routes.timeTable);
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: MyFloatingActionButton(
        onPressed: _navigateToCreateClass,
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
