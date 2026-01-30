import 'package:flutter_bloc/flutter_bloc.dart';

import 'timetable_state.dart';

export 'timetable_state.dart';

/// Cubit for managing the Weekly Timetable flow state.
class TimetableCubit extends Cubit<TimetableState> {
  TimetableCubit() : super(const TimetableState());

  /// Initialize and fetch all dropdown data.
  /// If [isEditMode] is true, also fetches existing timetable data.
  Future<void> initialize({bool isEditMode = false}) async {
    emit(state.copyWith(isInitialLoading: true, isEditMode: isEditMode));

    try {
      // Simulate parallel API calls
      final results = await Future.wait([
        _fetchTeachers(),
        if (isEditMode) _fetchExistingTimetable(),
      ]);

      final teachers = results[0] as List<TeacherModel>;

      if (isEditMode && results.length > 1) {
        final existingData = results[1] as Map<TimetableDay, List<PeriodModel>>;
        emit(
          state.copyWith(
            isInitialLoading: false,
            teachers: teachers,
            mondayPeriods: existingData[TimetableDay.monday] ?? [],
            tuesdayPeriods: existingData[TimetableDay.tuesday] ?? [],
            wednesdayPeriods: existingData[TimetableDay.wednesday] ?? [],
            thursdayPeriods: existingData[TimetableDay.thursday] ?? [],
            fridayPeriods: existingData[TimetableDay.friday] ?? [],
          ),
        );
      } else {
        emit(state.copyWith(isInitialLoading: false, teachers: teachers));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load data. Please try again.',
        ),
      );
    }
  }

  /// Simulates fetching teachers from API.
  Future<List<TeacherModel>> _fetchTeachers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return const [
      TeacherModel(id: '1', name: 'Mr. Smith'),
      TeacherModel(id: '2', name: 'Mrs. Johnson'),
      TeacherModel(id: '3', name: 'Mr. Brown'),
      TeacherModel(id: '4', name: 'Ms. Davis'),
      TeacherModel(id: '5', name: 'Mr. Wilson'),
      TeacherModel(id: '6', name: 'Mrs. Martinez'),
      TeacherModel(id: '7', name: 'Mr. Anderson'),
      TeacherModel(id: '8', name: 'Ms. Taylor'),
    ];
  }

  /// Simulates fetching existing timetable data for edit mode.
  Future<Map<TimetableDay, List<PeriodModel>>> _fetchExistingTimetable() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Sample existing timetable data
    return {
      TimetableDay.monday: List.generate(
        7,
        (index) => const PeriodModel(
          subject: 'English',
          teacherId: '1',
          teacherName: 'Mr. Smith',
        ),
      ),
      TimetableDay.tuesday: List.generate(
        7,
        (index) => const PeriodModel(
          subject: 'English',
          teacherId: '1',
          teacherName: 'Mr. Smith',
        ),
      ),
      TimetableDay.wednesday: List.generate(
        7,
        (index) => const PeriodModel(
          subject: 'English',
          teacherId: '1',
          teacherName: 'Mr. Smith',
        ),
      ),
      TimetableDay.thursday: List.generate(
        7,
        (index) => const PeriodModel(
          subject: 'English',
          teacherId: '1',
          teacherName: 'Mr. Smith',
        ),
      ),
      TimetableDay.friday: List.generate(
        7,
        (index) => const PeriodModel(
          subject: 'English',
          teacherId: '1',
          teacherName: 'Mr. Smith',
        ),
      ),
    };
  }

  // ==================== Step Navigation ====================

  /// Move to the next step.
  void goToNextStep() {
    final nextStep = _getNextStep(state.currentStep);
    if (nextStep != null) {
      emit(state.copyWith(currentStep: nextStep));
    }
  }

  /// Move to the previous step.
  void goToPreviousStep() {
    final previousStep = _getPreviousStep(state.currentStep);
    if (previousStep != null) {
      emit(state.copyWith(currentStep: previousStep));
    }
  }

  /// Go to a specific day for editing (used in preview).
  void goToDay(TimetableDay day) {
    emit(state.copyWith(currentStep: day));
  }

  TimetableDay? _getNextStep(TimetableDay current) {
    switch (current) {
      case TimetableDay.monday:
        return TimetableDay.tuesday;
      case TimetableDay.tuesday:
        return TimetableDay.wednesday;
      case TimetableDay.wednesday:
        return TimetableDay.thursday;
      case TimetableDay.thursday:
        return TimetableDay.friday;
      case TimetableDay.friday:
        return TimetableDay.preview;
      case TimetableDay.preview:
        return null;
    }
  }

  TimetableDay? _getPreviousStep(TimetableDay current) {
    switch (current) {
      case TimetableDay.monday:
        return null;
      case TimetableDay.tuesday:
        return TimetableDay.monday;
      case TimetableDay.wednesday:
        return TimetableDay.tuesday;
      case TimetableDay.thursday:
        return TimetableDay.wednesday;
      case TimetableDay.friday:
        return TimetableDay.thursday;
      case TimetableDay.preview:
        return TimetableDay.friday;
    }
  }

  // ==================== Period Management ====================

  /// Add a new period to the current day.
  void addPeriod() {
    final currentPeriods = _getCurrentPeriods();
    final updatedPeriods = List<PeriodModel>.from(currentPeriods)
      ..add(const PeriodModel());
    _updateCurrentDayPeriods(updatedPeriods);
  }

  /// Remove a period at the given index from the current day.
  void removePeriod(int index) {
    final currentPeriods = _getCurrentPeriods();
    if (index >= 0 && index < currentPeriods.length) {
      final updatedPeriods = List<PeriodModel>.from(currentPeriods)
        ..removeAt(index);
      _updateCurrentDayPeriods(updatedPeriods);
    }
  }

  /// Update the subject for a period at the given index.
  void updatePeriodSubject(int index, String value) {
    final currentPeriods = _getCurrentPeriods();
    if (index >= 0 && index < currentPeriods.length) {
      final updatedPeriods = List<PeriodModel>.from(currentPeriods);
      updatedPeriods[index] = updatedPeriods[index].copyWith(subject: value);
      _updateCurrentDayPeriods(updatedPeriods);
    }
  }

  /// Update the teacher for a period at the given index.
  void updatePeriodTeacher(int index, TeacherModel? teacher) {
    final currentPeriods = _getCurrentPeriods();
    if (index >= 0 && index < currentPeriods.length) {
      final updatedPeriods = List<PeriodModel>.from(currentPeriods);
      updatedPeriods[index] = updatedPeriods[index].copyWith(
        teacherId: teacher?.id,
        teacherName: teacher?.name,
      );
      _updateCurrentDayPeriods(updatedPeriods);
    }
  }

  List<PeriodModel> _getCurrentPeriods() {
    switch (state.currentStep) {
      case TimetableDay.monday:
        return state.mondayPeriods;
      case TimetableDay.tuesday:
        return state.tuesdayPeriods;
      case TimetableDay.wednesday:
        return state.wednesdayPeriods;
      case TimetableDay.thursday:
        return state.thursdayPeriods;
      case TimetableDay.friday:
        return state.fridayPeriods;
      case TimetableDay.preview:
        return [];
    }
  }

  void _updateCurrentDayPeriods(List<PeriodModel> periods) {
    switch (state.currentStep) {
      case TimetableDay.monday:
        emit(state.copyWith(mondayPeriods: periods));
        break;
      case TimetableDay.tuesday:
        emit(state.copyWith(tuesdayPeriods: periods));
        break;
      case TimetableDay.wednesday:
        emit(state.copyWith(wednesdayPeriods: periods));
        break;
      case TimetableDay.thursday:
        emit(state.copyWith(thursdayPeriods: periods));
        break;
      case TimetableDay.friday:
        emit(state.copyWith(fridayPeriods: periods));
        break;
      case TimetableDay.preview:
        break;
    }
  }

  // ==================== Form Submission ====================

  /// Submit the timetable.
  Future<void> submitTimetable() async {
    emit(state.copyWith(submissionStatus: TimetableSubmissionStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Log timetable data (in real app, send to API)
      _logTimetableData();

      emit(state.copyWith(submissionStatus: TimetableSubmissionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: TimetableSubmissionStatus.failure,
          errorMessage: 'Failed to save timetable. Please try again.',
        ),
      );
    }
  }

  void _logTimetableData() {
    // For debugging purposes
    print('=== Timetable Data ===');
    for (final day in state.allDaysTimetable) {
      print('${day.dayName}:');
      for (int i = 0; i < day.periods.length; i++) {
        final period = day.periods[i];
        print(
          '  Period ${i + 1}: ${period.subject} - ${period.teacherName ?? "No teacher"}',
        );
      }
    }
  }

  /// Reset the submission status.
  void resetSubmissionStatus() {
    emit(state.copyWith(submissionStatus: TimetableSubmissionStatus.initial));
  }

  /// Clear error message.
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
