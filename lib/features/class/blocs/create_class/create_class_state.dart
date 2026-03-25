import 'package:equatable/equatable.dart';

import '../../models/academic_year_model.dart';
import '../../models/school_user_model.dart';

/// Enum for the submission status.
enum SubmissionStatus { initial, loading, success, failure }

/// Immutable state class for CreateClassCubit.
class CreateClassState extends Equatable {
  const CreateClassState({
    this.isInitialLoading = true,
    this.submissionStatus = SubmissionStatus.initial,
    this.errorMessage,
    this.isEditMode = false,
    this.classroomId,
    // Form fields
    this.className = '',
    this.roomNo = '',
    this.selectedAcademicYear,
    this.selectedClassTeacher,
    // Original values for edit mode (to detect changes)
    this.originalClassName,
    this.originalRoomNo,
    this.originalAcademicYear,
    this.originalClassTeacher,
  });

  // Flow state
  final bool isInitialLoading;
  final SubmissionStatus submissionStatus;
  final String? errorMessage;
  final bool isEditMode;
  final String? classroomId;

  // Form fields
  final String className;
  final String roomNo;
  final AcademicYearModel? selectedAcademicYear;
  final SchoolUserModel? selectedClassTeacher;

  // Original values for edit mode
  final String? originalClassName;
  final String? originalRoomNo;
  final AcademicYearModel? originalAcademicYear;
  final SchoolUserModel? originalClassTeacher;

  /// Helper getters
  bool get isSubmitting => submissionStatus == SubmissionStatus.loading;
  bool get isSuccess => submissionStatus == SubmissionStatus.success;
  bool get isFailure => submissionStatus == SubmissionStatus.failure;

  /// Validation for the form
  bool get isFormValid =>
      className.isNotEmpty &&
      selectedAcademicYear != null &&
      selectedClassTeacher != null;

  /// Check if any field has changed (for edit mode)
  bool get hasChanges {
    if (!isEditMode) return true;
    return className != originalClassName ||
        roomNo != originalRoomNo ||
        selectedAcademicYear?.id != originalAcademicYear?.id ||
        selectedClassTeacher?.id != originalClassTeacher?.id;
  }

  /// Get changed fields map for PATCH request
  Map<String, dynamic> get changedFields {
    final changes = <String, dynamic>{};
    if (className != originalClassName) {
      changes['name'] = className;
    }
    if (roomNo != originalRoomNo) {
      changes['room_number'] = roomNo;
    }
    if (selectedAcademicYear?.id != originalAcademicYear?.id &&
        selectedAcademicYear != null) {
      changes['academic_year'] = selectedAcademicYear!.id;
    }
    if (selectedClassTeacher?.id != originalClassTeacher?.id &&
        selectedClassTeacher != null) {
      changes['class_teacher'] = selectedClassTeacher!.id;
    }
    return changes;
  }

  CreateClassState copyWith({
    bool? isInitialLoading,
    SubmissionStatus? submissionStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isEditMode,
    String? classroomId,
    String? className,
    String? roomNo,
    AcademicYearModel? selectedAcademicYear,
    bool clearSelectedAcademicYear = false,
    SchoolUserModel? selectedClassTeacher,
    bool clearSelectedClassTeacher = false,
    String? originalClassName,
    String? originalRoomNo,
    AcademicYearModel? originalAcademicYear,
    SchoolUserModel? originalClassTeacher,
  }) {
    return CreateClassState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
      classroomId: classroomId ?? this.classroomId,
      className: className ?? this.className,
      roomNo: roomNo ?? this.roomNo,
      selectedAcademicYear: clearSelectedAcademicYear
          ? null
          : selectedAcademicYear ?? this.selectedAcademicYear,
      selectedClassTeacher: clearSelectedClassTeacher
          ? null
          : selectedClassTeacher ?? this.selectedClassTeacher,
      originalClassName: originalClassName ?? this.originalClassName,
      originalRoomNo: originalRoomNo ?? this.originalRoomNo,
      originalAcademicYear: originalAcademicYear ?? this.originalAcademicYear,
      originalClassTeacher: originalClassTeacher ?? this.originalClassTeacher,
    );
  }

  @override
  List<Object?> get props => [
    isInitialLoading,
    submissionStatus,
    errorMessage,
    isEditMode,
    classroomId,
    className,
    roomNo,
    selectedAcademicYear,
    selectedClassTeacher,
    originalClassName,
    originalRoomNo,
    originalAcademicYear,
    originalClassTeacher,
  ];
}
