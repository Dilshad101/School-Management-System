import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/permissions.dart';
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

  /// Helper to check if user has permission.
  bool _hasPermission(List<String> userPermissions, String permission) {
    return userPermissions.contains(permission);
  }

  /// Handles fetching all dashboard data based on permissions.
  Future<void> _onFetchRequested(
    DashboardFetchRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));

    final permissions = event.permissions;

    try {
      // Prepare futures based on permissions
      final futures = <Future<dynamic>>[];
      final futureKeys = <String>[];

      // Student/Employee count - requires view_student OR view_user
      if (_hasPermission(permissions, Permissions.viewStudent) ||
          _hasPermission(permissions, Permissions.viewUser)) {
        futures.add(_dashboardRepository.getStudentEmployeeCount());
        futureKeys.add('studentEmployeeCount');
      }

      // Pending fees - requires view_fee
      if (_hasPermission(permissions, Permissions.viewReports)) {
        futures.add(_dashboardRepository.getPendingFees());
        futureKeys.add('pendingFees');
        futures.add(_dashboardRepository.getLastSixMonthsPayments());
        futureKeys.add('lastSixMonthsPayments');
      }

      // TODO: Uncomment when API is ready
      // Timetable - requires view_timetable
      // if (_hasPermission(permissions, Permissions.viewTimetable)) {
      //   futures.add(_dashboardRepository.getTimetable());
      //   futureKeys.add('timetable');
      // }

      // Recently paid - requires view_fee OR view_student_fee_history
      // if (_hasPermission(permissions, Permissions.viewFee) ||
      //     _hasPermission(permissions, Permissions.viewStudentFeeHistory)) {
      //   futures.add(_dashboardRepository.getRecentlyPaid());
      //   futureKeys.add('recentlyPaid');
      // }

      // Fetch all permitted data in parallel
      final results = await Future.wait(futures);

      // Map results to their keys
      final resultMap = <String, dynamic>{};
      for (var i = 0; i < futureKeys.length; i++) {
        resultMap[futureKeys[i]] = results[i];
      }

      // Get mock data for timetable and recently paid (TODO: Remove when API ready)
      DashboardTimetable? mockTimetable;
      DashboardRecentlyPaid? mockRecentlyPaid;

      if (_hasPermission(permissions, Permissions.viewTimetable) ||
          _hasPermission(permissions, Permissions.viewTeacherTimetable)) {
        mockTimetable = _getMockTimetable();
      }

      if (_hasPermission(permissions, Permissions.viewFee) ||
          _hasPermission(permissions, Permissions.viewStudentFeeHistory)) {
        mockRecentlyPaid = _getMockRecentlyPaid();
      }

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          studentEmployeeCount:
              resultMap['studentEmployeeCount'] as StudentEmployeeCount?,
          pendingFees: resultMap['pendingFees'] as PendingFees?,
          lastSixMonthsPayments:
              resultMap['lastSixMonthsPayments'] as LastSixMonthsPayments?,
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

  /// Handles refreshing dashboard data based on permissions.
  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final permissions = event.permissions;

    try {
      // Prepare futures based on permissions
      final futures = <Future<dynamic>>[];
      final futureKeys = <String>[];

      if (_hasPermission(permissions, Permissions.viewStudent) ||
          _hasPermission(permissions, Permissions.viewUser)) {
        futures.add(_dashboardRepository.getStudentEmployeeCount());
        futureKeys.add('studentEmployeeCount');
      }

      if (_hasPermission(permissions, Permissions.viewReports)) {
        futures.add(_dashboardRepository.getPendingFees());
        futureKeys.add('pendingFees');
        futures.add(_dashboardRepository.getLastSixMonthsPayments());
        futureKeys.add('lastSixMonthsPayments');
      }

      final results = await Future.wait(futures);

      final resultMap = <String, dynamic>{};
      for (var i = 0; i < futureKeys.length; i++) {
        resultMap[futureKeys[i]] = results[i];
      }

      // Get mock data (TODO: Remove when API ready)
      DashboardTimetable? mockTimetable;
      DashboardRecentlyPaid? mockRecentlyPaid;

      if (_hasPermission(permissions, Permissions.viewTimetable) ||
          _hasPermission(permissions, Permissions.viewTeacherTimetable)) {
        mockTimetable = _getMockTimetable();
      }

      if (_hasPermission(permissions, Permissions.viewFee) ||
          _hasPermission(permissions, Permissions.viewStudentFeeHistory)) {
        mockRecentlyPaid = _getMockRecentlyPaid();
      }

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          studentEmployeeCount:
              resultMap['studentEmployeeCount'] as StudentEmployeeCount? ??
              state.studentEmployeeCount,
          pendingFees:
              resultMap['pendingFees'] as PendingFees? ?? state.pendingFees,
          lastSixMonthsPayments:
              resultMap['lastSixMonthsPayments'] as LastSixMonthsPayments? ??
              state.lastSixMonthsPayments,
          timetable: mockTimetable ?? state.timetable,
          recentlyPaid: mockRecentlyPaid ?? state.recentlyPaid,
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
