import 'package:equatable/equatable.dart';

/// Enum for the current day step in the timetable flow.
enum TimetableDay { monday, tuesday, wednesday, thursday, friday, preview }

/// Enum for the submission status.
enum TimetableSubmissionStatus { initial, loading, success, failure }

/// Model for a period entry (immutable).
class PeriodModel extends Equatable {
  const PeriodModel({this.subject = '', this.teacherId, this.teacherName});

  final String subject;
  final String? teacherId;
  final String? teacherName;

  PeriodModel copyWith({
    String? subject,
    String? teacherId,
    String? teacherName,
  }) {
    return PeriodModel(
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  bool get isValid => subject.isNotEmpty && teacherId != null;

  @override
  List<Object?> get props => [subject, teacherId, teacherName];
}

/// Model for a teacher (immutable).
class TeacherModel extends Equatable {
  const TeacherModel({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Model for a day's timetable (immutable).
class DayTimetable extends Equatable {
  const DayTimetable({required this.day, this.periods = const []});

  final TimetableDay day;
  final List<PeriodModel> periods;

  DayTimetable copyWith({TimetableDay? day, List<PeriodModel>? periods}) {
    return DayTimetable(day: day ?? this.day, periods: periods ?? this.periods);
  }

  String get dayName {
    switch (day) {
      case TimetableDay.monday:
        return 'Monday';
      case TimetableDay.tuesday:
        return 'Tuesday';
      case TimetableDay.wednesday:
        return 'Wednesday';
      case TimetableDay.thursday:
        return 'Thursday';
      case TimetableDay.friday:
        return 'Friday';
      case TimetableDay.preview:
        return 'Preview';
    }
  }

  @override
  List<Object?> get props => [day, periods];
}

/// Immutable state class for TimetableCubit.
class TimetableState extends Equatable {
  const TimetableState({
    this.currentStep = TimetableDay.monday,
    this.isInitialLoading = true,
    this.submissionStatus = TimetableSubmissionStatus.initial,
    this.errorMessage,
    this.isEditMode = false,
    // Timetable data for each day
    this.mondayPeriods = const [],
    this.tuesdayPeriods = const [],
    this.wednesdayPeriods = const [],
    this.thursdayPeriods = const [],
    this.fridayPeriods = const [],
    // Dropdown data
    this.teachers = const [],
  });

  // Flow state
  final TimetableDay currentStep;
  final bool isInitialLoading;
  final TimetableSubmissionStatus submissionStatus;
  final String? errorMessage;
  final bool isEditMode;

  // Periods for each day
  final List<PeriodModel> mondayPeriods;
  final List<PeriodModel> tuesdayPeriods;
  final List<PeriodModel> wednesdayPeriods;
  final List<PeriodModel> thursdayPeriods;
  final List<PeriodModel> fridayPeriods;

  // Dropdown data (fetched from API)
  final List<TeacherModel> teachers;

  /// Helper getters
  bool get isSubmitting =>
      submissionStatus == TimetableSubmissionStatus.loading;
  bool get isSuccess => submissionStatus == TimetableSubmissionStatus.success;
  bool get isFailure => submissionStatus == TimetableSubmissionStatus.failure;
  bool get isOnPreviewStep => currentStep == TimetableDay.preview;

  /// Get step index (0-5)
  int get currentStepIndex {
    switch (currentStep) {
      case TimetableDay.monday:
        return 0;
      case TimetableDay.tuesday:
        return 1;
      case TimetableDay.wednesday:
        return 2;
      case TimetableDay.thursday:
        return 3;
      case TimetableDay.friday:
        return 4;
      case TimetableDay.preview:
        return 5;
    }
  }

  /// Get current day name
  String get currentDayName {
    switch (currentStep) {
      case TimetableDay.monday:
        return 'Monday';
      case TimetableDay.tuesday:
        return 'Tuesday';
      case TimetableDay.wednesday:
        return 'Wednesday';
      case TimetableDay.thursday:
        return 'Thursday';
      case TimetableDay.friday:
        return 'Friday';
      case TimetableDay.preview:
        return 'Preview';
    }
  }

  /// Get periods for current day
  List<PeriodModel> get currentDayPeriods {
    switch (currentStep) {
      case TimetableDay.monday:
        return mondayPeriods;
      case TimetableDay.tuesday:
        return tuesdayPeriods;
      case TimetableDay.wednesday:
        return wednesdayPeriods;
      case TimetableDay.thursday:
        return thursdayPeriods;
      case TimetableDay.friday:
        return fridayPeriods;
      case TimetableDay.preview:
        return [];
    }
  }

  /// Get all days timetable for preview
  List<DayTimetable> get allDaysTimetable => [
    DayTimetable(day: TimetableDay.monday, periods: mondayPeriods),
    DayTimetable(day: TimetableDay.tuesday, periods: tuesdayPeriods),
    DayTimetable(day: TimetableDay.wednesday, periods: wednesdayPeriods),
    DayTimetable(day: TimetableDay.thursday, periods: thursdayPeriods),
    DayTimetable(day: TimetableDay.friday, periods: fridayPeriods),
  ];

  /// Check if current day has valid periods
  bool get isCurrentDayValid {
    final periods = currentDayPeriods;
    if (periods.isEmpty) return true; // Empty is valid, user can skip
    return periods.every((p) => p.isValid);
  }

  TimetableState copyWith({
    TimetableDay? currentStep,
    bool? isInitialLoading,
    TimetableSubmissionStatus? submissionStatus,
    String? errorMessage,
    bool? isEditMode,
    List<PeriodModel>? mondayPeriods,
    List<PeriodModel>? tuesdayPeriods,
    List<PeriodModel>? wednesdayPeriods,
    List<PeriodModel>? thursdayPeriods,
    List<PeriodModel>? fridayPeriods,
    List<TeacherModel>? teachers,
  }) {
    return TimetableState(
      currentStep: currentStep ?? this.currentStep,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
      mondayPeriods: mondayPeriods ?? this.mondayPeriods,
      tuesdayPeriods: tuesdayPeriods ?? this.tuesdayPeriods,
      wednesdayPeriods: wednesdayPeriods ?? this.wednesdayPeriods,
      thursdayPeriods: thursdayPeriods ?? this.thursdayPeriods,
      fridayPeriods: fridayPeriods ?? this.fridayPeriods,
      teachers: teachers ?? this.teachers,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isInitialLoading,
    submissionStatus,
    errorMessage,
    isEditMode,
    mondayPeriods,
    tuesdayPeriods,
    wednesdayPeriods,
    thursdayPeriods,
    fridayPeriods,
    teachers,
  ];
}
