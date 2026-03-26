import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/academic_year_repository.dart';
import 'academic_year_state.dart';

/// Cubit for managing academic year state.
class AcademicYearCubit extends Cubit<AcademicYearState> {
  AcademicYearCubit({
    required AcademicYearRepository academicYearRepository,
    required String schoolId,
  }) : _academicYearRepository = academicYearRepository,
       _schoolId = schoolId,
       super(const AcademicYearState());

  final AcademicYearRepository _academicYearRepository;
  final String _schoolId;

  static const int _pageSize = 10;

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Fetches the initial list of academic years.
  Future<void> fetchAcademicYears({String? search}) async {
    emit(
      state.copyWith(
        status: AcademicYearStatus.loading,
        searchQuery: search ?? state.searchQuery,
      ),
    );

    try {
      final response = await _academicYearRepository.getAcademicYears(
        page: 1,
        pageSize: _pageSize,
        search: search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          status: AcademicYearStatus.success,
          academicYears: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AcademicYearStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Loads more academic years (pagination).
  Future<void> loadMoreAcademicYears() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(status: AcademicYearStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _academicYearRepository.getAcademicYears(
        page: nextPage,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(
        state.copyWith(
          status: AcademicYearStatus.success,
          academicYears: [...state.academicYears, ...response.results],
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AcademicYearStatus.success,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Creates a new academic year.
  Future<bool> createAcademicYear({
    required String name,
    required String startDate,
    required String endDate,
  }) async {
    emit(state.copyWith(actionStatus: AcademicYearActionStatus.loading));

    try {
      final newAcademicYear = await _academicYearRepository.createAcademicYear(
        name: name,
        startDate: startDate,
        endDate: endDate,
        schoolId: _schoolId,
      );

      // Add the new academic year to the list
      final updatedList = [...state.academicYears, newAcademicYear];
      // Sort by name (descending - newest first)
      updatedList.sort((a, b) => b.name.compareTo(a.name));

      emit(
        state.copyWith(
          actionStatus: AcademicYearActionStatus.success,
          academicYears: updatedList,
          totalCount: state.totalCount + 1,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AcademicYearActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Updates an existing academic year.
  Future<bool> updateAcademicYear({
    required String id,
    required String name,
    required String startDate,
    required String endDate,
  }) async {
    emit(state.copyWith(actionStatus: AcademicYearActionStatus.loading));

    try {
      final updatedAcademicYear = await _academicYearRepository
          .updateAcademicYear(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
          );

      // Update the academic year in the list
      final updatedList = state.academicYears.map((item) {
        return item.id == id ? updatedAcademicYear : item;
      }).toList();
      // Sort by name (descending - newest first)
      updatedList.sort((a, b) => b.name.compareTo(a.name));

      emit(
        state.copyWith(
          actionStatus: AcademicYearActionStatus.success,
          academicYears: updatedList,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AcademicYearActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Deletes an academic year.
  Future<bool> deleteAcademicYear({required String id}) async {
    emit(state.copyWith(actionStatus: AcademicYearActionStatus.loading));

    try {
      await _academicYearRepository.deleteAcademicYear(id: id);

      // Remove the academic year from the list
      final updatedList = state.academicYears
          .where((item) => item.id != id)
          .toList();

      emit(
        state.copyWith(
          actionStatus: AcademicYearActionStatus.success,
          academicYears: updatedList,
          totalCount: state.totalCount - 1,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AcademicYearActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Clears the action status.
  void clearActionStatus() {
    emit(
      state.copyWith(
        actionStatus: AcademicYearActionStatus.idle,
        actionError: null,
      ),
    );
  }

  /// Clears any error.
  void clearError() {
    emit(state.copyWith(error: null));
  }
}
