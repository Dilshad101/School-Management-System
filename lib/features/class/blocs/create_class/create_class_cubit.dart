import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/tenant/tenant_context.dart';
import '../../../../core/utils/di.dart';
import '../../models/academic_year_model.dart';
import '../../models/school_user_model.dart';
import '../../repositories/classroom_repository.dart';
import 'create_class_state.dart';

export 'create_class_state.dart';

/// Cubit for managing the Create/Edit Class form state.
class CreateClassCubit extends Cubit<CreateClassState> {
  CreateClassCubit({required ClassroomRepository repository})
    : _repository = repository,
      super(const CreateClassState());

  final ClassroomRepository _repository;

  /// Initialize for creating a new class.
  Future<void> initialize() async {
    emit(state.copyWith(isInitialLoading: false, isEditMode: false));
  }

  /// Initialize for editing an existing class.
  Future<void> initializeForEdit(String classroomId) async {
    emit(state.copyWith(isInitialLoading: true, isEditMode: true));

    try {
      final classroom = await _repository.getClassroomById(classroomId);

      // Convert classroom data to form state
      AcademicYearModel? academicYear;
      if (classroom.academicYearDetails != null) {
        academicYear = AcademicYearModel(
          id: classroom.academicYearDetails!.id,
          name: classroom.academicYearDetails!.name,
          startDate: classroom.academicYearDetails!.startDate,
          endDate: classroom.academicYearDetails!.endDate,
          isCurrent: classroom.academicYearDetails!.isCurrent,
          school: classroom.academicYearDetails!.school,
        );
      }

      SchoolUserModel? classTeacher;
      if (classroom.classTeacherDetails != null) {
        classTeacher = SchoolUserModel(
          id: classroom.classTeacherDetails!.id,
          email: classroom.classTeacherDetails!.email ?? '',
          firstName: classroom.classTeacherDetails!.name,
          isActive: true,
        );
      }

      emit(
        state.copyWith(
          isInitialLoading: false,
          isEditMode: true,
          classroomId: classroomId,
          className: classroom.name,
          roomNo: classroom.code.split('-').length > 1
              ? ''
              : '', // Room number not in response
          selectedAcademicYear: academicYear,
          selectedClassTeacher: classTeacher,
          originalClassName: classroom.name,
          originalRoomNo: '',
          originalAcademicYear: academicYear,
          originalClassTeacher: classTeacher,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isInitialLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load classroom data. Please try again.',
        ),
      );
    }
  }

  // ==================== Form Field Updates ====================

  /// Update the class name.
  void updateClassName(String value) {
    emit(state.copyWith(className: value));
  }

  /// Update the room number.
  void updateRoomNo(String value) {
    emit(state.copyWith(roomNo: value));
  }

  /// Update the selected academic year.
  void updateAcademicYear(AcademicYearModel? value) {
    emit(
      state.copyWith(
        selectedAcademicYear: value,
        clearSelectedAcademicYear: value == null,
      ),
    );
  }

  /// Update the selected class teacher.
  void updateClassTeacher(SchoolUserModel? value) {
    emit(
      state.copyWith(
        selectedClassTeacher: value,
        clearSelectedClassTeacher: value == null,
      ),
    );
  }

  // ==================== Search APIs ====================

  /// Search academic years.
  Future<List<AcademicYearModel>> searchAcademicYears(String query) async {
    try {
      final response = await _repository.getAcademicYears(search: query);
      return response.results;
    } catch (e) {
      return [];
    }
  }

  /// Search school users (teachers).
  Future<List<SchoolUserModel>> searchSchoolUsers(String query) async {
    try {
      final response = await _repository.getSchoolUsers(search: query);
      return response.results;
    } catch (e) {
      return [];
    }
  }

  // ==================== Form Submission ====================

  /// Submit the form - creates or updates based on mode.
  Future<void> submitForm() async {
    if (!state.isFormValid) {
      emit(state.copyWith(errorMessage: 'Please fill all required fields'));
      return;
    }

    emit(state.copyWith(submissionStatus: SubmissionStatus.loading));

    try {
      final schoolId = locator<TenantContext>().selectedSchoolId;
      if (schoolId == null) {
        throw const ApiException(message: 'School ID not found');
      }

      if (state.isEditMode && state.classroomId != null) {
        // Update existing classroom
        if (!state.hasChanges) {
          emit(state.copyWith(submissionStatus: SubmissionStatus.success));
          return;
        }

        final changes = state.changedFields;
        await _repository.updateClassroom(
          id: state.classroomId!,
          name: changes['name'],
          academicYear: changes['academic_year'],
          classTeacher: changes['class_teacher'],
          roomNumber: changes['room_number'],
        );
      } else {
        // Create new classroom
        await _repository.createClassroom(
          name: state.className.trim(),
          academicYear: state.selectedAcademicYear!.id,
          classTeacher: state.selectedClassTeacher!.id,
          school: schoolId,
          roomNumber: state.roomNo.trim().isNotEmpty
              ? state.roomNo.trim()
              : null,
        );
      }

      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage:
              'Failed to ${state.isEditMode ? 'update' : 'create'} class. Please try again.',
        ),
      );
    }
  }

  /// Reset the form to initial state for adding another class.
  void resetForm() {
    emit(const CreateClassState(isInitialLoading: false));
  }

  /// Reset submission status (e.g., after showing dialog).
  void resetSubmissionStatus() {
    emit(state.copyWith(submissionStatus: SubmissionStatus.initial));
  }

  /// Clear any error message.
  void clearError() {
    emit(state.copyWith(clearErrorMessage: true));
  }
}
