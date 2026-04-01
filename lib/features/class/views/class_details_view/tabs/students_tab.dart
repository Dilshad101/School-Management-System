import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/route_paths.dart';
import '../../../../../core/utils/di.dart';
import '../../../../../shared/styles/app_styles.dart';
import '../../../../../shared/widgets/input_fields/search_field.dart';
import '../../../../students/repositories/students_repository.dart';
import '../../../blocs/class_students/class_students_cubit.dart';
import '../widgets/class_students_tile.dart';

class ClassStudentsTabView extends StatelessWidget {
  const ClassStudentsTabView({super.key, required this.classroomId});

  final String classroomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ClassStudentsCubit(studentsRepository: locator<StudentsRepository>())
            ..fetchStudents(classroomId),
      child: _ClassStudentsContent(classroomId: classroomId),
    );
  }
}

class _ClassStudentsContent extends StatefulWidget {
  const _ClassStudentsContent({required this.classroomId});

  final String classroomId;

  @override
  State<_ClassStudentsContent> createState() => _ClassStudentsContentState();
}

class _ClassStudentsContentState extends State<_ClassStudentsContent> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ClassStudentsCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        AppSearchBar(
          onChanged: (value) {
            context.read<ClassStudentsCubit>().search(value);
          },
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BlocConsumer<ClassStudentsCubit, ClassStudentsState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.hasError && state.students.isEmpty) {
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
                        'Failed to load students',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.borderError,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context
                            .read<ClassStudentsCubit>()
                            .fetchStudents(widget.classroomId),
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
                        Icons.people_outline,
                        size: 48,
                        color: AppColors.textSecondary.withAlpha(100),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
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
                  await context.read<ClassStudentsCubit>().refresh();
                },
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: state.hasMore
                      ? state.students.length + 1
                      : state.students.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >= state.students.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final student = state.students[index];
                    return ClassStudentTile(
                      student: student,
                      onTap: () {
                        context.push(
                          Routes.studentDetail.replaceFirst(
                            ':id',
                            student.id ?? '',
                          ),
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
    );
  }
}
