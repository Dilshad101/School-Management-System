import 'package:equatable/equatable.dart';

import '../../models/dashboard_models.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.studentEmployeeCount,
    this.pendingFees,
    this.lastSixMonthsPayments,
    this.error,
  });

  final DashboardStatus status;
  final StudentEmployeeCount? studentEmployeeCount;
  final PendingFees? pendingFees;
  final LastSixMonthsPayments? lastSixMonthsPayments;
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

  DashboardState copyWith({
    DashboardStatus? status,
    StudentEmployeeCount? studentEmployeeCount,
    PendingFees? pendingFees,
    LastSixMonthsPayments? lastSixMonthsPayments,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      studentEmployeeCount: studentEmployeeCount ?? this.studentEmployeeCount,
      pendingFees: pendingFees ?? this.pendingFees,
      lastSixMonthsPayments:
          lastSixMonthsPayments ?? this.lastSixMonthsPayments,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    studentEmployeeCount,
    pendingFees,
    lastSixMonthsPayments,
    error,
  ];
}
