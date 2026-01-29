import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_class_state.dart';

export 'create_class_state.dart';

/// Cubit for managing the Create Class flow state.
class CreateClassCubit extends Cubit<CreateClassState> {
  CreateClassCubit() : super(const CreateClassState());

  /// Initialize and fetch all dropdown data.
  /// Uses Future.wait() to simulate parallel API calls.
  Future<void> initialize() async {
    emit(state.copyWith(isInitialLoading: true));

    try {
      // Simulate parallel API calls using Future.wait
      final results = await Future.wait([_fetchDivisions(), _fetchTeachers()]);

      final divisions = results[0];
      final teachers = results[1];

      emit(
        state.copyWith(
          isInitialLoading: false,
          divisions: divisions,
          teachers: teachers,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load data. Please try again.',
        ),
      );
    }
  }

  /// Simulates fetching divisions from API.
  Future<List<String>> _fetchDivisions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return ['A', 'B', 'C', 'D', 'E'];
  }

  /// Simulates fetching teachers from API.
  Future<List<String>> _fetchTeachers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      'Thomas',
      'Sarah Johnson',
      'Michael Brown',
      'Emily Davis',
      'Robert Wilson',
      'Jennifer Martinez',
      'David Anderson',
      'Lisa Taylor',
    ];
  }

  // ==================== Step Navigation ====================

  /// Move to the next step (from Class Details to Subjects).
  void goToNextStep() {
    if (state.currentStep == CreateClassStep.classDetails) {
      emit(state.copyWith(currentStep: CreateClassStep.subjects));
    }
  }

  /// Move to the previous step (from Subjects to Class Details).
  void goToPreviousStep() {
    if (state.currentStep == CreateClassStep.subjects) {
      emit(state.copyWith(currentStep: CreateClassStep.classDetails));
    }
  }

  // ==================== Step 1: Class Details ====================

  /// Update the class name.
  void updateClassName(String value) {
    emit(state.copyWith(className: value));
  }

  /// Update the selected division.
  void updateDivision(String? value) {
    emit(state.copyWith(selectedDivision: value));
  }

  /// Update the room number.
  void updateRoomNo(String value) {
    emit(state.copyWith(roomNo: value));
  }

  /// Update the academic year.
  void updateAcademicYear(String value) {
    emit(state.copyWith(academicYear: value));
  }

  /// Update the class teacher.
  void updateClassTeacher(String value) {
    emit(state.copyWith(classTeacher: value));
  }

  // ==================== Step 2: Subjects ====================

  /// Add a new subject-teacher pair.
  void addSubject() {
    final updatedSubjects = List<SubjectTeacherModel>.from(state.subjects)
      ..add(const SubjectTeacherModel());
    emit(state.copyWith(subjects: updatedSubjects));
  }

  /// Remove a subject at the given index.
  void removeSubject(int index) {
    if (state.subjects.length > 1 &&
        index >= 0 &&
        index < state.subjects.length) {
      final updatedSubjects = List<SubjectTeacherModel>.from(state.subjects)
        ..removeAt(index);
      emit(state.copyWith(subjects: updatedSubjects));
    }
  }

  /// Update the subject name at the given index.
  void updateSubjectName(int index, String value) {
    if (index >= 0 && index < state.subjects.length) {
      final updatedSubjects = List<SubjectTeacherModel>.from(state.subjects);
      updatedSubjects[index] = updatedSubjects[index].copyWith(
        subjectName: value,
      );
      emit(state.copyWith(subjects: updatedSubjects));
    }
  }

  /// Update the teacher for a subject at the given index.
  void updateSubjectTeacher(int index, String? value) {
    if (index >= 0 && index < state.subjects.length) {
      final updatedSubjects = List<SubjectTeacherModel>.from(state.subjects);
      updatedSubjects[index] = updatedSubjects[index].copyWith(
        teacherName: value,
      );
      emit(state.copyWith(subjects: updatedSubjects));
    }
  }

  // ==================== Form Submission ====================

  /// Submit the form and create the class.
  Future<void> submitForm() async {
    emit(state.copyWith(submissionStatus: SubmissionStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success
      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: 'Failed to create class. Please try again.',
        ),
      );
    }
  }

  /// Reset the form to initial state for adding another class.
  void resetForm() {
    emit(
      CreateClassState(
        isInitialLoading: false,
        divisions: state.divisions,
        teachers: state.teachers,
      ),
    );
  }

  /// Reset submission status (e.g., after showing dialog).
  void resetSubmissionStatus() {
    emit(state.copyWith(submissionStatus: SubmissionStatus.initial));
  }
}
