import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../models/dashboard_models.dart';
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
        // TODO: Uncomment when API is ready
        // _dashboardRepository.getTimetable(),
        // _dashboardRepository.getRecentlyPaid(),
      ]);

      // Get mock data for timetable and recently paid
      final mockTimetable = _getMockTimetable();
      final mockRecentlyPaid = _getMockRecentlyPaid();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          studentEmployeeCount: results[0] as dynamic,
          pendingFees: results[1] as dynamic,
          lastSixMonthsPayments: results[2] as dynamic,
          // TODO: Replace with API data when ready
          // timetable: results[3] as DashboardTimetable,
          // recentlyPaid: results[4] as DashboardRecentlyPaid,
          timetable: mockTimetable,
          recentlyPaid: mockRecentlyPaid,
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
        // TODO: Uncomment when API is ready
        // _dashboardRepository.getTimetable(),
        // _dashboardRepository.getRecentlyPaid(),
      ]);

      // Get mock data for timetable and recently paid
      final mockTimetable = _getMockTimetable();
      final mockRecentlyPaid = _getMockRecentlyPaid();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          studentEmployeeCount: results[0] as dynamic,
          pendingFees: results[1] as dynamic,
          lastSixMonthsPayments: results[2] as dynamic,
          // TODO: Replace with API data when ready
          // timetable: results[3] as DashboardTimetable,
          // recentlyPaid: results[4] as DashboardRecentlyPaid,
          timetable: mockTimetable,
          recentlyPaid: mockRecentlyPaid,
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

  /// Returns mock timetable data.
  /// TODO: Remove when API is ready
  DashboardTimetable _getMockTimetable() {
    return const DashboardTimetable(
      periods: [
        TimetablePeriod(
          id: '1',
          periodNumber: 1,
          startTime: '08:30 AM',
          endTime: '09:15 AM',
          subjectName: 'Mathematics',
          className: 'Class 10 A',
          roomName: 'Room A 3',
          status: TimetablePeriodStatus.completed,
        ),
        TimetablePeriod(
          id: '2',
          periodNumber: 2,
          startTime: '08:30 AM',
          endTime: '09:15 AM',
          subjectName: 'Mathematics',
          className: 'Class 10 A',
          roomName: 'Room A 3',
          status: TimetablePeriodStatus.completed,
        ),
        TimetablePeriod(
          id: '3',
          periodNumber: 2,
          startTime: '08:30 AM',
          endTime: '09:15 AM',
          subjectName: 'Mathematics',
          className: 'Class 10 A',
          roomName: 'Room A 3',
          status: TimetablePeriodStatus.liveNow,
        ),
        TimetablePeriod(
          id: '4',
          periodNumber: 4,
          startTime: '08:30 AM',
          endTime: '09:15 AM',
          subjectName: 'Mathematics',
          className: 'Class 10 A',
          roomName: 'Room A 3',
          status: TimetablePeriodStatus.upcoming,
        ),
        TimetablePeriod(
          id: '5',
          periodNumber: 5,
          startTime: '08:30 AM',
          endTime: '09:15 AM',
          subjectName: 'Mathematics',
          className: 'Class 10 A',
          roomName: 'Room A 3',
          status: TimetablePeriodStatus.upcoming,
        ),
      ],
    );
  }

  /// Returns mock recently paid data.
  /// TODO: Remove when API is ready
  DashboardRecentlyPaid _getMockRecentlyPaid() {
    return DashboardRecentlyPaid(
      payments: [
        RecentlyPaidFee(
          id: '1',
          studentName: 'Priya',
          className: '8 A',
          studentId: 'ID 64452',
          totalFees: 1200,
          paidAmount: 1000,
          dueAmount: 200,
          paymentMethod: PaymentMethod.bank,
          paidAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        RecentlyPaidFee(
          id: '2',
          studentName: 'Priya',
          className: '8 A',
          studentId: 'ID 64452',
          totalFees: 1200,
          paidAmount: 1000,
          dueAmount: 200,
          paymentMethod: PaymentMethod.cash,
          paidAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        RecentlyPaidFee(
          id: '3',
          studentName: 'Priya',
          className: '8 A',
          studentId: 'ID 64452',
          totalFees: 1200,
          paidAmount: 1000,
          dueAmount: 200,
          paymentMethod: PaymentMethod.bank,
          paidAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}
