import 'package:equatable/equatable.dart';

/// Enum for the current step in the create class flow.
enum CreateClassStep { classDetails, subjects }

/// Enum for the submission status.
enum SubmissionStatus { initial, loading, success, failure }

/// Model for a subject-teacher pair (immutable).
class SubjectTeacherModel extends Equatable {
  const SubjectTeacherModel({this.subjectName = '', this.teacherName});

  final String subjectName;
  final String? teacherName;

  SubjectTeacherModel copyWith({String? subjectName, String? teacherName}) {
    return SubjectTeacherModel(
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  @override
  List<Object?> get props => [subjectName, teacherName];
}

/// Immutable state class for CreateClassCubit.
class CreateClassState extends Equatable {
  const CreateClassState({
    this.currentStep = CreateClassStep.classDetails,
    this.isInitialLoading = true,
    this.submissionStatus = SubmissionStatus.initial,
    this.errorMessage,
    // Step 1 fields
    this.className = '',
    this.selectedDivision,
    this.roomNo = '',
    this.academicYear = '',
    this.classTeacher = '',
    // Step 2 fields
    this.subjects = const [],
    // Dropdown data
    this.divisions = const [],
    this.teachers = const [],
  });

  // Flow state
  final CreateClassStep currentStep;
  final bool isInitialLoading;
  final SubmissionStatus submissionStatus;
  final String? errorMessage;

  // Step 1 fields
  final String className;
  final String? selectedDivision;
  final String roomNo;
  final String academicYear;
  final String classTeacher;

  // Step 2 fields
  final List<SubjectTeacherModel> subjects;

  // Dropdown data (fetched from API)
  final List<String> divisions;
  final List<String> teachers;

  /// Helper getters
  bool get isSubmitting => submissionStatus == SubmissionStatus.loading;
  bool get isSuccess => submissionStatus == SubmissionStatus.success;
  bool get isFailure => submissionStatus == SubmissionStatus.failure;
  bool get isOnClassDetailsStep => currentStep == CreateClassStep.classDetails;
  bool get isOnSubjectsStep => currentStep == CreateClassStep.subjects;

  /// Validation for step 1
  bool get isStep1Valid =>
      className.isNotEmpty &&
      selectedDivision != null &&
      roomNo.isNotEmpty &&
      academicYear.isNotEmpty &&
      classTeacher.isNotEmpty;

  /// Get the formatted class name (e.g., "8 - B")
  String get formattedClassName =>
      '$className${selectedDivision != null ? ' - $selectedDivision' : ''}';

  CreateClassState copyWith({
    CreateClassStep? currentStep,
    bool? isInitialLoading,
    SubmissionStatus? submissionStatus,
    String? errorMessage,
    String? className,
    String? selectedDivision,
    String? roomNo,
    String? academicYear,
    String? classTeacher,
    List<SubjectTeacherModel>? subjects,
    List<String>? divisions,
    List<String>? teachers,
  }) {
    return CreateClassState(
      currentStep: currentStep ?? this.currentStep,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage,
      className: className ?? this.className,
      selectedDivision: selectedDivision ?? this.selectedDivision,
      roomNo: roomNo ?? this.roomNo,
      academicYear: academicYear ?? this.academicYear,
      classTeacher: classTeacher ?? this.classTeacher,
      subjects: subjects ?? this.subjects,
      divisions: divisions ?? this.divisions,
      teachers: teachers ?? this.teachers,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isInitialLoading,
    submissionStatus,
    errorMessage,
    className,
    selectedDivision,
    roomNo,
    academicYear,
    classTeacher,
    subjects,
    divisions,
    teachers,
  ];
}
