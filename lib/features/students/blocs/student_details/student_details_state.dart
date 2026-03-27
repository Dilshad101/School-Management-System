import 'package:equatable/equatable.dart';

import '../../models/fee_details_model.dart';
import '../../models/student_model.dart';

enum StudentDetailsStatus { initial, loading, success, failure }

enum StudentDetailsActionStatus { idle, loading, success, failure }

class StudentDetailsState extends Equatable {
  const StudentDetailsState({
    this.status = StudentDetailsStatus.initial,
    this.student,
    this.feeDetails,
    this.error,
    this.selectedTabIndex = 0,
    this.isEditMode = false,
    this.actionStatus = StudentDetailsActionStatus.idle,
    this.actionError,
  });

  final StudentDetailsStatus status;
  final StudentModel? student;
  final StudentFeeDetailsResponse? feeDetails;
  final String? error;
  final int selectedTabIndex;
  final bool isEditMode;
  final StudentDetailsActionStatus actionStatus;
  final String? actionError;

  // Status helpers
  bool get isLoading => status == StudentDetailsStatus.loading;
  bool get isSuccess => status == StudentDetailsStatus.success;
  bool get hasError => status == StudentDetailsStatus.failure;

  // Action status helpers
  bool get isActionLoading =>
      actionStatus == StudentDetailsActionStatus.loading;
  bool get isActionSuccess =>
      actionStatus == StudentDetailsActionStatus.success;
  bool get isActionFailure =>
      actionStatus == StudentDetailsActionStatus.failure;

  // Tab names
  static const List<String> tabNames = [
    'Student Info',
    'Guardian Info',
    'Fee Summary',
  ];

  String get selectedTabName {
    if (selectedTabIndex >= 0 && selectedTabIndex < tabNames.length) {
      return tabNames[selectedTabIndex];
    }
    return tabNames[0];
  }

  StudentDetailsState copyWith({
    StudentDetailsStatus? status,
    StudentModel? student,
    StudentFeeDetailsResponse? feeDetails,
    String? error,
    int? selectedTabIndex,
    bool? isEditMode,
    StudentDetailsActionStatus? actionStatus,
    String? actionError,
  }) {
    return StudentDetailsState(
      status: status ?? this.status,
      student: student ?? this.student,
      feeDetails: feeDetails ?? this.feeDetails,
      error: error ?? this.error,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isEditMode: isEditMode ?? this.isEditMode,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError ?? this.actionError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    student,
    feeDetails,
    error,
    selectedTabIndex,
    isEditMode,
    actionStatus,
    actionError,
  ];
}
