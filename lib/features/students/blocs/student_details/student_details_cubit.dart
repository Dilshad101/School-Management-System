import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/students_repository.dart';
import 'student_details_state.dart';

class StudentDetailsCubit extends Cubit<StudentDetailsState> {
  StudentDetailsCubit({required StudentsRepository studentsRepository})
    : _studentsRepository = studentsRepository,
      super(const StudentDetailsState());

  final StudentsRepository _studentsRepository;

  /// Fetches student details and fee details.
  Future<void> fetchStudentDetails(String studentId) async {
    emit(state.copyWith(status: StudentDetailsStatus.loading));

    try {
      // Fetch student details and fee details in parallel
      final results = await Future.wait([
        _studentsRepository.getStudentById(studentId),
        _studentsRepository.getStudentFeeDetails(studentId),
      ]);

      emit(
        state.copyWith(
          status: StudentDetailsStatus.success,
          student: results[0] as dynamic,
          feeDetails: results[1] as dynamic,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StudentDetailsStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Changes the selected tab.
  void selectTab(int index) {
    if (index >= 0 && index < StudentDetailsState.tabNames.length) {
      emit(state.copyWith(selectedTabIndex: index));
    }
  }

  /// Toggles edit mode.
  void toggleEditMode() {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  /// Enables edit mode.
  void enableEditMode() {
    emit(state.copyWith(isEditMode: true));
  }

  /// Disables edit mode.
  void disableEditMode() {
    emit(state.copyWith(isEditMode: false));
  }

  /// Clears the action status.
  void clearActionStatus() {
    emit(
      state.copyWith(
        actionStatus: StudentDetailsActionStatus.idle,
        actionError: null,
      ),
    );
  }

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
