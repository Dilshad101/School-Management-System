import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/classroom_repository.dart';
import 'class_timetable_state.dart';

class ClassTimetableCubit extends Cubit<ClassTimetableState> {
  ClassTimetableCubit({
    required ClassroomRepository classroomRepository,
    required this.classroomId,
    required this.academicYearId,
    required this.schoolId,
  }) : _classroomRepository = classroomRepository,
       super(const ClassTimetableState());

  final ClassroomRepository _classroomRepository;
  final String classroomId;
  final String academicYearId;
  final String schoolId;

  /// Fetches the timetable for the classroom.
  Future<void> fetchTimetable() async {
    emit(state.copyWith(status: ClassTimetableStatus.loading));

    try {
      final response = await _classroomRepository.getClassroomTimetable(
        classroomId: classroomId,
        academicYearId: academicYearId,
      );

      emit(
        state.copyWith(
          status: ClassTimetableStatus.success,
          periods: response.periods,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ClassTimetableStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  /// Changes the selected day.
  void selectDay(int dayIndex) {
    if (dayIndex >= 0 && dayIndex < ClassTimetableState.dayNames.length) {
      emit(state.copyWith(selectedDayIndex: dayIndex));
    }
  }

  /// Moves to the next day.
  void nextDay() {
    if (state.selectedDayIndex < ClassTimetableState.dayNames.length - 1) {
      emit(state.copyWith(selectedDayIndex: state.selectedDayIndex + 1));
    }
  }

  /// Moves to the previous day.
  void previousDay() {
    if (state.selectedDayIndex > 0) {
      emit(state.copyWith(selectedDayIndex: state.selectedDayIndex - 1));
    }
  }

  /// Saves a timetable entry (create or update).
  Future<void> saveTimetableEntry({
    required String periodId,
    required int dayOfWeek,
    required String subjectId,
    required String teacherId,
  }) async {
    emit(state.copyWith(actionStatus: ClassTimetableActionStatus.loading));

    try {
      await _classroomRepository.saveTimetableEntries(
        schoolId: schoolId,
        academicYearId: academicYearId,
        classroomId: classroomId,
        entries: [
          TimetableEntryPayload(
            dayOfWeek: dayOfWeek,
            periodId: periodId,
            teacherId: teacherId,
            subjectId: subjectId,
          ),
        ],
      );

      emit(state.copyWith(actionStatus: ClassTimetableActionStatus.success));

      // Refresh the timetable after saving
      await fetchTimetable();
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: ClassTimetableActionStatus.failure,
          actionError: e.toString(),
        ),
      );
    }
  }

  /// Clears the action status.
  void clearActionStatus() {
    emit(
      state.copyWith(
        actionStatus: ClassTimetableActionStatus.idle,
        actionError: null,
      ),
    );
  }
}
