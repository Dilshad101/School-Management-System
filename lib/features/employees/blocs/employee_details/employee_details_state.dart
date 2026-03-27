import 'package:equatable/equatable.dart';

import '../../models/employee_model.dart';

enum EmployeeDetailsStatus { initial, loading, success, failure }

enum EmployeeDetailsActionStatus { idle, loading, success, failure }

class EmployeeDetailsState extends Equatable {
  const EmployeeDetailsState({
    this.status = EmployeeDetailsStatus.initial,
    this.employee,
    this.error,
    this.isEditMode = false,
    this.actionStatus = EmployeeDetailsActionStatus.idle,
    this.actionError,
    this.isTogglingActive = false,
  });

  final EmployeeDetailsStatus status;
  final EmployeeModel? employee;
  final String? error;
  final bool isEditMode;
  final EmployeeDetailsActionStatus actionStatus;
  final String? actionError;
  final bool isTogglingActive;

  // Status helpers
  bool get isLoading => status == EmployeeDetailsStatus.loading;
  bool get isSuccess => status == EmployeeDetailsStatus.success;
  bool get hasError => status == EmployeeDetailsStatus.failure;

  // Action status helpers
  bool get isActionLoading =>
      actionStatus == EmployeeDetailsActionStatus.loading;
  bool get isActionSuccess =>
      actionStatus == EmployeeDetailsActionStatus.success;
  bool get isActionFailure =>
      actionStatus == EmployeeDetailsActionStatus.failure;

  EmployeeDetailsState copyWith({
    EmployeeDetailsStatus? status,
    EmployeeModel? employee,
    String? error,
    bool? isEditMode,
    EmployeeDetailsActionStatus? actionStatus,
    String? actionError,
    bool? isTogglingActive,
  }) {
    return EmployeeDetailsState(
      status: status ?? this.status,
      employee: employee ?? this.employee,
      error: error ?? this.error,
      isEditMode: isEditMode ?? this.isEditMode,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError ?? this.actionError,
      isTogglingActive: isTogglingActive ?? this.isTogglingActive,
    );
  }

  @override
  List<Object?> get props => [
    status,
    employee,
    error,
    isEditMode,
    actionStatus,
    actionError,
    isTogglingActive,
  ];
}
