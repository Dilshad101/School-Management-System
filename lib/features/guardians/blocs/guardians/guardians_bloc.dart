import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/guardians_repository.dart';
import 'guardians_event.dart';
import 'guardians_state.dart';

/// BLoC for managing guardians list state.
class GuardiansBloc extends Bloc<GuardiansEvent, GuardiansState> {
  GuardiansBloc({required GuardiansRepository guardiansRepository})
    : _guardiansRepository = guardiansRepository,
      super(const GuardiansState()) {
    on<GuardiansFetchRequested>(_onFetchRequested);
    on<GuardiansLoadMoreRequested>(_onLoadMoreRequested);
    on<GuardiansSearchRequested>(_onSearchRequested);
    on<GuardiansSearchCleared>(_onSearchCleared);
    on<GuardiansClassFilterChanged>(_onClassFilterChanged);
    on<GuardiansDivisionFilterChanged>(_onDivisionFilterChanged);
    on<GuardiansFiltersCleared>(_onFiltersCleared);
    on<GuardiansErrorCleared>(_onErrorCleared);
    on<GuardianDeleteRequested>(_onDeleteRequested);
    on<GuardianAddedSuccessfully>(_onGuardianAdded);
  }

  final GuardiansRepository _guardiansRepository;

  static const int _pageSize = 10;

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> _onFetchRequested(
    GuardiansFetchRequested event,
    Emitter<GuardiansState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GuardiansStatus.loading,
        searchQuery: event.search ?? state.searchQuery,
        selectedClassId: event.classId,
        selectedDivisionId: event.divisionId,
        clearError: true,
      ),
    );

    try {
      final response = await _guardiansRepository.getGuardians(
        page: event.page,
        pageSize: _pageSize,
        search: event.search ?? state.searchQuery,
        classId: event.classId ?? state.selectedClassId,
        divisionId: event.divisionId ?? state.selectedDivisionId,
      );

      emit(
        state.copyWith(
          status: GuardiansStatus.success,
          guardians: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GuardiansStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    GuardiansLoadMoreRequested event,
    Emitter<GuardiansState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(status: GuardiansStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _guardiansRepository.getGuardians(
        page: nextPage,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        classId: state.selectedClassId,
        divisionId: state.selectedDivisionId,
      );

      emit(
        state.copyWith(
          status: GuardiansStatus.success,
          guardians: [...state.guardians, ...response.results],
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GuardiansStatus.success,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onSearchRequested(
    GuardiansSearchRequested event,
    Emitter<GuardiansState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GuardiansStatus.loading,
        searchQuery: event.query,
        clearError: true,
      ),
    );

    try {
      final response = await _guardiansRepository.getGuardians(
        page: 1,
        pageSize: _pageSize,
        search: event.query,
        classId: state.selectedClassId,
        divisionId: state.selectedDivisionId,
      );

      emit(
        state.copyWith(
          status: GuardiansStatus.success,
          guardians: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
          searchQuery: event.query,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GuardiansStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onSearchCleared(
    GuardiansSearchCleared event,
    Emitter<GuardiansState> emit,
  ) async {
    add(const GuardiansFetchRequested(search: ''));
  }

  Future<void> _onClassFilterChanged(
    GuardiansClassFilterChanged event,
    Emitter<GuardiansState> emit,
  ) async {
    add(
      GuardiansFetchRequested(
        classId: event.classId,
        divisionId: state.selectedDivisionId,
      ),
    );
  }

  Future<void> _onDivisionFilterChanged(
    GuardiansDivisionFilterChanged event,
    Emitter<GuardiansState> emit,
  ) async {
    add(
      GuardiansFetchRequested(
        classId: state.selectedClassId,
        divisionId: event.divisionId,
      ),
    );
  }

  Future<void> _onFiltersCleared(
    GuardiansFiltersCleared event,
    Emitter<GuardiansState> emit,
  ) async {
    emit(state.copyWith(clearClassFilter: true, clearDivisionFilter: true));
    add(const GuardiansFetchRequested());
  }

  void _onErrorCleared(
    GuardiansErrorCleared event,
    Emitter<GuardiansState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _onDeleteRequested(
    GuardianDeleteRequested event,
    Emitter<GuardiansState> emit,
  ) async {
    emit(state.copyWith(status: GuardiansStatus.deleting));

    try {
      await _guardiansRepository.deleteGuardian(event.guardianId);

      final updatedGuardians = state.guardians
          .where((g) => g.id != event.guardianId)
          .toList();

      emit(
        state.copyWith(
          status: GuardiansStatus.deleteSuccess,
          guardians: updatedGuardians,
          totalCount: state.totalCount - 1,
          successMessage: 'Guardian deleted successfully',
        ),
      );

      // Reset to success status after showing message
      emit(state.copyWith(status: GuardiansStatus.success, clearSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          status: GuardiansStatus.deleteFailure,
          error: _getErrorMessage(e),
        ),
      );

      // Reset to success status to allow retry
      emit(state.copyWith(status: GuardiansStatus.success));
    }
  }

  Future<void> _onGuardianAdded(
    GuardianAddedSuccessfully event,
    Emitter<GuardiansState> emit,
  ) async {
    // Refresh the list when a guardian is added
    add(const GuardiansFetchRequested(refresh: true));
  }
}
