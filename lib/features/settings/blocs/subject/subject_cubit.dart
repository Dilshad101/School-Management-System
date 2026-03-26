import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/subject_repository.dart';
import 'subject_state.dart';

/// Cubit for managing subject state.
class SubjectCubit extends Cubit<SubjectState> {
  SubjectCubit({
    required SubjectRepository subjectRepository,
    required String schoolId,
  }) : _subjectRepository = subjectRepository,
       _schoolId = schoolId,
       super(const SubjectState());

  final SubjectRepository _subjectRepository;
  final String _schoolId;

  static const int _pageSize = 10;

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Fetches the initial list of subjects.
  Future<void> fetchSubjects({String? search}) async {
    emit(
      state.copyWith(
        status: SubjectStatus.loading,
        searchQuery: search ?? state.searchQuery,
      ),
    );

    try {
      final response = await _subjectRepository.getSubjects(
        page: 1,
        pageSize: _pageSize,
        search: search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          status: SubjectStatus.success,
          subjects: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SubjectStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Loads more subjects (pagination).
  Future<void> loadMoreSubjects() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(status: SubjectStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _subjectRepository.getSubjects(
        page: nextPage,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(
        state.copyWith(
          status: SubjectStatus.success,
          subjects: [...state.subjects, ...response.results],
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SubjectStatus.success,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Creates a new subject.
  Future<bool> createSubject({
    required String name,
    required String code,
    required bool isLab,
  }) async {
    emit(state.copyWith(actionStatus: SubjectActionStatus.loading));

    try {
      final newSubject = await _subjectRepository.createSubject(
        name: name,
        code: code,
        isLab: isLab,
        schoolId: _schoolId,
      );

      // Add the new subject to the list
      final updatedSubjects = [...state.subjects, newSubject];
      // Sort by name
      updatedSubjects.sort((a, b) => a.name.compareTo(b.name));

      emit(
        state.copyWith(
          actionStatus: SubjectActionStatus.success,
          subjects: updatedSubjects,
          totalCount: state.totalCount + 1,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: SubjectActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Updates an existing subject.
  Future<bool> updateSubject({
    required String id,
    required String name,
    required String code,
    required bool isLab,
  }) async {
    emit(state.copyWith(actionStatus: SubjectActionStatus.loading));

    try {
      final updatedSubject = await _subjectRepository.updateSubject(
        id: id,
        name: name,
        code: code,
        isLab: isLab,
      );

      // Update the subject in the list
      final updatedSubjects = state.subjects.map((subject) {
        return subject.id == id ? updatedSubject : subject;
      }).toList();
      // Sort by name
      updatedSubjects.sort((a, b) => a.name.compareTo(b.name));

      emit(
        state.copyWith(
          actionStatus: SubjectActionStatus.success,
          subjects: updatedSubjects,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: SubjectActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Deletes a subject.
  Future<bool> deleteSubject({required String id}) async {
    emit(state.copyWith(actionStatus: SubjectActionStatus.loading));

    try {
      await _subjectRepository.deleteSubject(id: id);

      // Remove the subject from the list
      final updatedSubjects = state.subjects
          .where((subject) => subject.id != id)
          .toList();

      emit(
        state.copyWith(
          actionStatus: SubjectActionStatus.success,
          subjects: updatedSubjects,
          totalCount: state.totalCount - 1,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: SubjectActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Clears the action status.
  void clearActionStatus() {
    emit(
      state.copyWith(actionStatus: SubjectActionStatus.idle, actionError: null),
    );
  }

  /// Clears any error.
  void clearError() {
    emit(state.copyWith(error: null));
  }
}
