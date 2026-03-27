import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

export 'dashboard_event.dart';
export 'dashboard_state.dart';

/// BLoC for managing dashboard state.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository,
      super(const DashboardState()) {
    on<DashboardFetchRequested>(_onFetchRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardErrorCleared>(_onErrorCleared);
  }

  final DashboardRepository _dashboardRepository;

  /// Handles fetching all dashboard data.
  Future<void> _onFetchRequested(
    DashboardFetchRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _dashboardRepository.getStudentEmployeeCount(),
        _dashboardRepository.getPendingFees(),
        _dashboardRepository.getLastSixMonthsPayments(),
      ]);

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          studentEmployeeCount: results[0] as dynamic,
          pendingFees: results[1] as dynamic,
          lastSixMonthsPayments: results[2] as dynamic,
        ),
      );
    } on ApiException catch (e, s) {
      log('DashboardBloc._onFetchRequested error: $e trace: $s');
      emit(state.copyWith(status: DashboardStatus.failure, error: e.message));
    } catch (e, s) {
      log('DashboardBloc._onFetchRequested error: $e trace: $s');
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          error: 'Failed to load dashboard data. Please try again.',
        ),
      );
    }
  }

  /// Handles refreshing dashboard data.
  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Don't show loading indicator for refresh, just refetch
    try {
      final results = await Future.wait([
        _dashboardRepository.getStudentEmployeeCount(),
        _dashboardRepository.getPendingFees(),
        _dashboardRepository.getLastSixMonthsPayments(),
      ]);

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          studentEmployeeCount: results[0] as dynamic,
          pendingFees: results[1] as dynamic,
          lastSixMonthsPayments: results[2] as dynamic,
          clearError: true,
        ),
      );
    } on ApiException catch (e, s) {
      log('DashboardBloc._onRefreshRequested error: $e trace: $s');
      emit(state.copyWith(error: e.message));
    } catch (e, s) {
      log('DashboardBloc._onRefreshRequested error: $e trace: $s');
      emit(state.copyWith(error: 'Failed to refresh dashboard data.'));
    }
  }

  /// Clears error message.
  void _onErrorCleared(
    DashboardErrorCleared event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }
}
