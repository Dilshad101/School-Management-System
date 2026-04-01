import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../students/repositories/students_repository.dart';
import 'class_students_state.dart';

export 'class_students_state.dart';

/// Cubit for managing class students list with pagination.
class ClassStudentsCubit extends Cubit<ClassStudentsState> {
  ClassStudentsCubit({required StudentsRepository studentsRepository})
    : _studentsRepository = studentsRepository,
      super(const ClassStudentsState());

  final StudentsRepository _studentsRepository;
  String? _classroomId;

  /// Fetches the initial list of students for a classroom.
  Future<void> fetchStudents(String classroomId, {String? search}) async {
    _classroomId = classroomId;
    emit(
      state.copyWith(
        status: ClassStudentsStatus.loading,
        searchQuery: search ?? '',
        clearError: true,
      ),
    );

    try {
      final response = await _studentsRepository.getStudents(
        page: 1,
        classroomId: classroomId,
        search: search,
      );

      emit(
        state.copyWith(
          status: ClassStudentsStatus.success,
          students: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } on ApiException catch (e, s) {
      log('ClassStudentsCubit.fetchStudents error: $e trace: $s');
      emit(
        state.copyWith(status: ClassStudentsStatus.failure, error: e.message),
      );
    } catch (e, s) {
      log('ClassStudentsCubit.fetchStudents error: $e trace: $s');
      emit(
        state.copyWith(
          status: ClassStudentsStatus.failure,
          error: 'Failed to load students. Please try again.',
        ),
      );
    }
  }

  /// Loads the next page of students.
  Future<void> loadMore() async {
    if (_classroomId == null ||
        state.isLoadingMore ||
        state.isLoading ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(status: ClassStudentsStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _studentsRepository.getStudents(
        page: nextPage,
        classroomId: _classroomId!,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(
        state.copyWith(
          status: ClassStudentsStatus.success,
          students: [...state.students, ...response.results],
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } on ApiException catch (e, s) {
      log('ClassStudentsCubit.loadMore error: $e trace: $s');
      emit(
        state.copyWith(status: ClassStudentsStatus.success, error: e.message),
      );
    } catch (e, s) {
      log('ClassStudentsCubit.loadMore error: $e trace: $s');
      emit(
        state.copyWith(
          status: ClassStudentsStatus.success,
          error: 'Failed to load more students.',
        ),
      );
    }
  }

  /// Searches for students by query.
  Future<void> search(String query) async {
    if (_classroomId == null) return;
    await fetchStudents(_classroomId!, search: query);
  }

  /// Refreshes the student list.
  Future<void> refresh() async {
    if (_classroomId == null) return;
    await fetchStudents(
      _classroomId!,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );
  }
}
