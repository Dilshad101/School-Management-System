import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/period_repository.dart';
import 'period_state.dart';

/// Cubit for managing period state.
class PeriodCubit extends Cubit<PeriodState> {
  PeriodCubit({
    required PeriodRepository periodRepository,
    required String schoolId,
  }) : _periodRepository = periodRepository,
       _schoolId = schoolId,
       super(const PeriodState());

  final PeriodRepository _periodRepository;
  final String _schoolId;

  static const int _pageSize = 10;

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Fetches the initial list of periods.
  Future<void> fetchPeriods({String? search}) async {
    emit(
      state.copyWith(
        status: PeriodStatus.loading,
        searchQuery: search ?? state.searchQuery,
      ),
    );

    try {
      final response = await _periodRepository.getPeriods(
        page: 1,
        pageSize: _pageSize,
        search: search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          status: PeriodStatus.success,
          periods: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PeriodStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Loads more periods (pagination).
  Future<void> loadMorePeriods() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(status: PeriodStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _periodRepository.getPeriods(
        page: nextPage,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(
        state.copyWith(
          status: PeriodStatus.success,
          periods: [...state.periods, ...response.results],
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PeriodStatus.success,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Creates a new period.
  Future<bool> createPeriod({
    required String startTime,
    required String endTime,
    required int order,
  }) async {
    emit(state.copyWith(actionStatus: PeriodActionStatus.loading));

    try {
      final newPeriod = await _periodRepository.createPeriod(
        startTime: startTime,
        endTime: endTime,
        order: order,
        schoolId: _schoolId,
      );

      // Add the new period to the list
      final updatedPeriods = [...state.periods, newPeriod];
      // Sort by order
      updatedPeriods.sort((a, b) => a.order.compareTo(b.order));

      emit(
        state.copyWith(
          actionStatus: PeriodActionStatus.success,
          periods: updatedPeriods,
          totalCount: state.totalCount + 1,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: PeriodActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Updates an existing period.
  Future<bool> updatePeriod({
    required String id,
    required String startTime,
    required String endTime,
    required int order,
  }) async {
    emit(state.copyWith(actionStatus: PeriodActionStatus.loading));

    try {
      final updatedPeriod = await _periodRepository.updatePeriod(
        id: id,
        startTime: startTime,
        endTime: endTime,
        order: order,
      );

      // Update the period in the list
      final updatedPeriods = state.periods.map((period) {
        return period.id == id ? updatedPeriod : period;
      }).toList();
      // Sort by order
      updatedPeriods.sort((a, b) => a.order.compareTo(b.order));

      emit(
        state.copyWith(
          actionStatus: PeriodActionStatus.success,
          periods: updatedPeriods,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: PeriodActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Deletes a period.
  Future<bool> deletePeriod({required String id}) async {
    emit(state.copyWith(actionStatus: PeriodActionStatus.loading));

    try {
      await _periodRepository.deletePeriod(id: id);

      // Remove the period from the list
      final updatedPeriods = state.periods
          .where((period) => period.id != id)
          .toList();

      emit(
        state.copyWith(
          actionStatus: PeriodActionStatus.success,
          periods: updatedPeriods,
          totalCount: state.totalCount - 1,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: PeriodActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Clears the action status.
  void clearActionStatus() {
    emit(
      state.copyWith(actionStatus: PeriodActionStatus.idle, actionError: null),
    );
  }

  /// Clears any error.
  void clearError() {
    emit(state.copyWith(error: null));
  }
}
