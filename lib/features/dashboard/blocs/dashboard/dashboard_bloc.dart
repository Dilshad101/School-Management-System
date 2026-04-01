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

      // Student timetable - requires view_student_timetable
      if (_hasPermission(permissions, Permissions.viewStudentTimetable)) {
        futures.add(_dashboardRepository.getStudentTimetable());
        futureKeys.add('studentTimetable');
      }

      // Teacher timetable - requires view_teacher_timetable
      if (_hasPermission(permissions, Permissions.viewTeacherTimetable)) {
        futures.add(_dashboardRepository.getTeacherTimetable());
        futureKeys.add('teacherTimetable');
      }

      // Recent fee payments - requires view_reports
      if (_hasPermission(permissions, Permissions.viewReports)) {
        futures.add(_dashboardRepository.getRecentFeePayments());
        futureKeys.add('recentlyPaid');
      }

      // TODO: Uncomment when API is ready
      // Timetable - requires view_timetable
      // if (_hasPermission(permissions, Permissions.viewTimetable)) {
      //   futures.add(_dashboardRepository.getTimetable());
      //   futureKeys.add('timetable');
      // }

      // Fetch all permitted data in parallel
      final results = await Future.wait(futures);

      // Map results to their keys
      final resultMap = <String, dynamic>{};
      for (var i = 0; i < futureKeys.length; i++) {
        resultMap[futureKeys[i]] = results[i];
      }

      // Get mock data for timetable (TODO: Remove when API ready)
      DashboardTimetable? mockTimetable;

      if (_hasPermission(permissions, Permissions.viewTimetable)) {
        mockTimetable = _getMockTimetable();
      }

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          studentEmployeeCount:
              resultMap['studentEmployeeCount'] as StudentEmployeeCount?,
          pendingFees: resultMap['pendingFees'] as PendingFees?,
          lastSixMonthsPayments:
              resultMap['lastSixMonthsPayments'] as LastSixMonthsPayments?,
          studentTimetable:
              resultMap['studentTimetable'] as TodayTimetableResponse?,
          teacherTimetable:
              resultMap['teacherTimetable'] as TodayTimetableResponse?,
          recentlyPaid: resultMap['recentlyPaid'] as DashboardRecentlyPaid?,
          timetable: mockTimetable,
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

      // Student timetable - requires view_student_timetable
      if (_hasPermission(permissions, Permissions.viewStudentTimetable)) {
        futures.add(_dashboardRepository.getStudentTimetable());
        futureKeys.add('studentTimetable');
      }

      // Teacher timetable - requires view_teacher_timetable
      if (_hasPermission(permissions, Permissions.viewTeacherTimetable)) {
        futures.add(_dashboardRepository.getTeacherTimetable());
        futureKeys.add('teacherTimetable');
      }

      // Recent fee payments - requires view_reports
      if (_hasPermission(permissions, Permissions.viewReports)) {
        futures.add(_dashboardRepository.getRecentFeePayments());
        futureKeys.add('recentlyPaid');
      }

      final results = await Future.wait(futures);

      final resultMap = <String, dynamic>{};
      for (var i = 0; i < futureKeys.length; i++) {
        resultMap[futureKeys[i]] = results[i];
      }

      // Get mock data (TODO: Remove when API ready)
      DashboardTimetable? mockTimetable;

      if (_hasPermission(permissions, Permissions.viewTimetable)) {
        mockTimetable = _getMockTimetable();
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
          studentTimetable:
              resultMap['studentTimetable'] as TodayTimetableResponse? ??
              state.studentTimetable,
          teacherTimetable:
              resultMap['teacherTimetable'] as TodayTimetableResponse? ??
              state.teacherTimetable,
          recentlyPaid:
              resultMap['recentlyPaid'] as DashboardRecentlyPaid? ??
              state.recentlyPaid,
          timetable: mockTimetable ?? state.timetable,
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
}

var d = {
  "success": true,
  "data": {
    "id": "09ce4a95-56ac-4ea0-95d8-418189aee3bd",
    "email": "mcaeo92595@minitts.net",
    "phone": "7894561212",
    "first_name": "dilshad",
    "last_name": null,
    "is_platform_admin": false,
    "is_active": true,
    "role": [
      {
        "id": "6ca492ba-23f3-4ea4-9632-df10c7e879bc",
        "user": "09ce4a95-56ac-4ea0-95d8-418189aee3bd",
        "school": "accec208-5989-4f96-855f-3b57afd98634",
        "roles": ["99ca7e8f-a26f-4f46-97fa-09925d69d096"],
        "role_names": ["Admin"],
        "status": "active",
        "joined_at": "2026-03-26T06:47:57.034501Z",
        "common_id": null,
      },
    ],
    "permission": [
      "change_school_type",
      "view_guardian_timetable",
      "delete_device",
      "view_exam",
      "change_user",
      "activate_user",
      "change_role",
      "delete_period",
      "manage_school_settings",
      "manage_attendance_events",
      "view_chat",
      "view_academic_year",
      "delete_subscription",
      "add_device",
      "delete_academic_year",
      "delete_feature",
      "view_subject",
      "view_attendance",
      "manage_attendance_sources",
      "add_academic_year",
      "view_audit_logs",
      "assign_role",
      "view_teacher_timetable",
      "view_notification",
      "add_transport",
      "change_period",
      "add_role",
      "view_student_fee_history",
      "view_school",
      "view_student_timetable",
      "change_notification",
      "view_timetable",
      "change_guardian",
      "deactivate_user",
      "view_student",
      "delete_student",
      "view_user_school",
      "change_subscription",
      "view_student_fee_details",
      "change_feature",
      "view_subscription",
      "change_timetable",
      "change_academic_year",
      "view_reports",
      "view_profile",
      "add_classroom",
      "view_timetable_availability",
      "view_user",
      "mark_attendance",
      "add_period",
      "view_feature",
      "delete_guardian",
      "add_timetable",
      "delete_user_school",
      "add_feature",
      "add_user",
      "add_plan",
      "delete_school",
      "delete_school_type",
      "add_exam",
      "change_school",
      "add_subscription",
      "delete_subject",
      "collect_payment",
      "delete_user",
      "view_student_transport_status",
      "change_transport",
      "delete_timetable",
      "add_user_school",
      "change_fee",
      "add_marks",
      "change_subject",
      "add_guardian",
      "delete_plan",
      "change_classroom",
      "add_transport_event",
      "add_school_type",
      "delete_notification",
      "change_device",
      "change_user_school",
      "view_fee",
      "delete_classroom",
      "change_plan",
      "delete_transport",
      "correct_attendance",
      "view_device",
      "view_transport",
      "send_notification",
      "view_role",
      "view_classroom",
      "delete_role",
      "add_student",
      "publish_marks",
      "send_message",
      "view_guardian",
      "view_school_type",
      "view_plan",
      "add_school",
      "view_permission",
      "view_marks",
      "publish_exam",
      "change_student",
      "export_attendance",
      "promote_student",
      "export_reports",
      "view_period",
      "access_admin_dashboard",
      "manage_attendance_identifiers",
      "refund_payment",
      "add_subject",
    ],
    "schools": [
      {
        "id": "6ca492ba-23f3-4ea4-9632-df10c7e879bc",
        "user": "09ce4a95-56ac-4ea0-95d8-418189aee3bd",
        "school": "accec208-5989-4f96-855f-3b57afd98634",
        "roles": ["99ca7e8f-a26f-4f46-97fa-09925d69d096"],
        "role_names": ["Admin"],
        "status": "active",
        "joined_at": "2026-03-26T06:47:57.034501Z",
        "common_id": null,
      },
    ],
    "is_superuser": false,
    "current_classroom_details": null,
  },
  "meta": {
    "request_id": "b8d4df16-b6b6-4a00-8791-4d2f369e10ba",
    "timestamp": "2026-04-01T10:47:49.269612+00:00",
    "debug": {"required_permission": null},
  },
};
