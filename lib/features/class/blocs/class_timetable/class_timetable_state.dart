import 'package:equatable/equatable.dart';

import '../../models/timetable_model.dart';

enum ClassTimetableStatus { initial, loading, success, failure }

enum ClassTimetableActionStatus { idle, loading, success, failure }

class ClassTimetableState extends Equatable {
  const ClassTimetableState({
    this.status = ClassTimetableStatus.initial,
    this.periods = const [],
    this.selectedDayIndex = 0,
    this.error,
    this.actionStatus = ClassTimetableActionStatus.idle,
    this.actionError,
  });

  final ClassTimetableStatus status;
  final List<PeriodWithTimetableModel> periods;
  final int selectedDayIndex;
  final String? error;
  final ClassTimetableActionStatus actionStatus;
  final String? actionError;

  bool get isLoading => status == ClassTimetableStatus.loading;
  bool get isSuccess => status == ClassTimetableStatus.success;
  bool get hasError => status == ClassTimetableStatus.failure;
  bool get isEmpty => periods.isEmpty && isSuccess;

  bool get isActionLoading =>
      actionStatus == ClassTimetableActionStatus.loading;
  bool get isActionSuccess =>
      actionStatus == ClassTimetableActionStatus.success;
  bool get isActionFailure =>
      actionStatus == ClassTimetableActionStatus.failure;

  static const List<String> dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  /// Gets the day name for the selected day index.
  String get selectedDayName {
    if (selectedDayIndex >= 0 && selectedDayIndex < dayNames.length) {
      return dayNames[selectedDayIndex];
    }
    return 'Monday';
  }

  ClassTimetableState copyWith({
    ClassTimetableStatus? status,
    List<PeriodWithTimetableModel>? periods,
    int? selectedDayIndex,
    String? error,
    ClassTimetableActionStatus? actionStatus,
    String? actionError,
  }) {
    return ClassTimetableState(
      status: status ?? this.status,
      periods: periods ?? this.periods,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      error: error ?? this.error,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError ?? this.actionError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    periods,
    selectedDayIndex,
    error,
    actionStatus,
    actionError,
  ];
}
