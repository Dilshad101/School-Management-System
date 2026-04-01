import 'package:equatable/equatable.dart';

import '../../models/dashboard_models.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.studentEmployeeCount,
    this.pendingFees,
    this.lastSixMonthsPayments,
    this.timetable,
    this.studentTimetable,
    this.teacherTimetable,
    this.recentlyPaid,
    this.error,
  });

  final DashboardStatus status;
  final StudentEmployeeCount? studentEmployeeCount;
  final PendingFees? pendingFees;
  final LastSixMonthsPayments? lastSixMonthsPayments;
  final DashboardTimetable? timetable;
  final TodayTimetableResponse? studentTimetable;
  final TodayTimetableResponse? teacherTimetable;
  final DashboardRecentlyPaid? recentlyPaid;
  final String? error;

  // Status helpers
  bool get isLoading => status == DashboardStatus.loading;
  bool get isSuccess => status == DashboardStatus.success;
  bool get hasError => status == DashboardStatus.failure;

  // Data helpers
  int get studentCount => studentEmployeeCount?.studentCount ?? 0;
  int get employeeCount => studentEmployeeCount?.employeeCount ?? 0;
  double get totalPendingFees => pendingFees?.totalPending ?? 0;
  String get formattedPendingFees => pendingFees?.formattedAmount ?? '₹0';

  // Timetable helpers (legacy)
  List<TimetablePeriod> get periods => timetable?.periods ?? [];
  bool get hasTimetable => periods.isNotEmpty;

  // Student timetable helpers
  List<TimetablePeriod> get studentPeriods =>
      studentTimetable?.toTimetablePeriods() ?? [];
  bool get hasStudentTimetable => studentPeriods.isNotEmpty;

  // Teacher timetable helpers
  List<TimetablePeriod> get teacherPeriods =>
      teacherTimetable?.toTimetablePeriods() ?? [];
  bool get hasTeacherTimetable => teacherPeriods.isNotEmpty;

  // Recently paid helpers
  List<RecentlyPaidFee> get recentPayments => recentlyPaid?.payments ?? [];
  bool get hasRecentPayments => recentPayments.isNotEmpty;

  DashboardState copyWith({
    DashboardStatus? status,
    StudentEmployeeCount? studentEmployeeCount,
    PendingFees? pendingFees,
    LastSixMonthsPayments? lastSixMonthsPayments,
    DashboardTimetable? timetable,
    TodayTimetableResponse? studentTimetable,
    TodayTimetableResponse? teacherTimetable,
    DashboardRecentlyPaid? recentlyPaid,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      studentEmployeeCount: studentEmployeeCount ?? this.studentEmployeeCount,
      pendingFees: pendingFees ?? this.pendingFees,
      lastSixMonthsPayments:
          lastSixMonthsPayments ?? this.lastSixMonthsPayments,
      timetable: timetable ?? this.timetable,
      studentTimetable: studentTimetable ?? this.studentTimetable,
      teacherTimetable: teacherTimetable ?? this.teacherTimetable,
      recentlyPaid: recentlyPaid ?? this.recentlyPaid,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    studentEmployeeCount,
    pendingFees,
    lastSixMonthsPayments,
    timetable,
    studentTimetable,
    teacherTimetable,
    recentlyPaid,
    error,
  ];
}
