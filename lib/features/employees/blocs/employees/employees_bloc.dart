import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/employees_repository.dart';
import 'employees_event.dart';
import 'employees_state.dart';

export 'employees_event.dart';
export 'employees_state.dart';

/// BLoC for managing the employees list state.
class EmployeesBloc extends Bloc<EmployeesEvent, EmployeesState> {
  EmployeesBloc({required EmployeesRepository employeesRepository})
    : _employeesRepository = employeesRepository,
      super(const EmployeesState()) {
    on<FetchEmployees>(_onFetchEmployees);
    on<SearchEmployees>(_onSearchEmployees);
    on<LoadMoreEmployees>(_onLoadMoreEmployees);
    on<RefreshEmployees>(_onRefreshEmployees);
    on<DeleteEmployee>(_onDeleteEmployee);
    on<ClearEmployeesError>(_onClearError);
  }

  final EmployeesRepository _employeesRepository;

  /// Debounce timer for search
  Timer? _searchDebounce;

  /// Handles fetching employees.
  Future<void> _onFetchEmployees(
    FetchEmployees event,
    Emitter<EmployeesState> emit,
  ) async {
    // Don't show loading if refreshing
    if (!event.refresh) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final response = await _employeesRepository.getEmployees(
        page: event.page,
        search: event.search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: true,
          employees: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasNext: response.hasNext,
          hasPrevious: response.hasPrevious,
          searchQuery: event.search ?? state.searchQuery,
        ),
      );
    } on ApiException catch (e, s) {
      log('$e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e, s) {
      log('$e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: false,
          errorMessage: 'Failed to fetch employees. Please try again.',
        ),
      );
    }
  }

  /// Handles searching employees with debounce.
  Future<void> _onSearchEmployees(
    SearchEmployees event,
    Emitter<EmployeesState> emit,
  ) async {
    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    // Update search query immediately for UI feedback
    emit(state.copyWith(searchQuery: event.query));

    // Debounce the actual search
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(FetchEmployees(page: 1, search: event.query));
    });
  }

  /// Handles loading more employees (pagination).
  Future<void> _onLoadMoreEmployees(
    LoadMoreEmployees event,
    Emitter<EmployeesState> emit,
  ) async {
    // Don't load more if already loading or no more pages
    if (!state.canLoadMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _employeesRepository.getEmployees(
        page: nextPage,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      // Append new employees to existing list
      final updatedEmployees = [...state.employees, ...response.results];

      emit(
        state.copyWith(
          isLoadingMore: false,
          employees: updatedEmployees,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasNext: response.hasNext,
          hasPrevious: response.hasPrevious,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Failed to load more employees.',
        ),
      );
    }
  }

  /// Handles refreshing employees list.
  Future<void> _onRefreshEmployees(
    RefreshEmployees event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    add(
      FetchEmployees(
        page: 1,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        refresh: true,
      ),
    );
  }

  /// Handles deleting an employee.
  Future<void> _onDeleteEmployee(
    DeleteEmployee event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, clearError: true));

    try {
      await _employeesRepository.deleteEmployee(event.employeeId);

      // Remove the deleted employee from the list
      final updatedEmployees = state.employees
          .where((e) => e.id != event.employeeId)
          .toList();

      emit(
        state.copyWith(
          isDeleting: false,
          isSuccess: true,
          employees: updatedEmployees,
          totalCount: state.totalCount - 1,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          isSuccess: false,
          errorMessage: 'Failed to delete employee. Please try again.',
        ),
      );
    }
  }

  /// Clears error message.
  void _onClearError(ClearEmployeesError event, Emitter<EmployeesState> emit) {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
