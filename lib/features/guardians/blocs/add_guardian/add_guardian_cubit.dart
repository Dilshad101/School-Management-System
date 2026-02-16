import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../models/guardian_model.dart';
import '../../models/create_guardian_request.dart';
import '../../repositories/guardians_repository.dart';
import 'add_guardian_state.dart';

/// Cubit for managing add/edit guardian form state.
class AddGuardianCubit extends Cubit<AddGuardianState> {
  AddGuardianCubit({
    required GuardiansRepository guardiansRepository,
    required String schoolId,
    String? guardianId, // Pass this for edit mode
  }) : _guardiansRepository = guardiansRepository,
       super(
         AddGuardianState(
           schoolId: schoolId,
           isEditMode: guardianId != null,
           guardianId: guardianId,
         ),
       ) {
    // If guardianId is provided, load the guardian details
    if (guardianId != null) {
      loadGuardianDetails(guardianId);
    }
  }

  final GuardiansRepository _guardiansRepository;

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Loads guardian details for edit mode.
  Future<void> loadGuardianDetails(String guardianId) async {
    emit(state.copyWith(status: AddGuardianStatus.loading, clearError: true));

    try {
      final guardian = await _guardiansRepository.getGuardianById(guardianId);

      // Convert relations to LinkedStudentModel
      final linkedStudents = guardian.relationsDetails.map((relation) {
        return LinkedStudentModel(
          id: relation.id,
          name: relation.studentName,
          className: relation.classroomName ?? '',
          profilePic: relation.profilePic,
          relation: relation.relation ?? '',
        );
      }).toList();

      emit(
        state.copyWith(
          status: AddGuardianStatus.initial,
          email: guardian.email,
          fullName: guardian.firstName ?? '',
          lastName: guardian.lastName ?? '',
          phone: guardian.phone ?? '',
          address: guardian.profile?.address ?? '',
          linkedStudents: linkedStudents,
          isActive: guardian.isActive,
          isEditable: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddGuardianStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Updates the email field.
  void updateEmail(String email) {
    // In edit mode, don't clear existing guardian or reset editable state
    if (state.isEditMode) {
      emit(state.copyWith(email: email, clearError: true));
    } else {
      emit(
        state.copyWith(
          email: email,
          clearError: true,
          clearExistingGuardian: true,
          status: AddGuardianStatus.initial,
          isEditable: true,
        ),
      );
    }
  }

  /// Updates the full name field.
  void updateFullName(String fullName) {
    emit(state.copyWith(fullName: fullName, clearError: true));
  }

  /// Updates the last name field.
  void updateLastName(String lastName) {
    emit(state.copyWith(lastName: lastName, clearError: true));
  }

  /// Updates the phone field.
  void updatePhone(String phone) {
    emit(state.copyWith(phone: phone, clearError: true));
  }

  /// Updates the address field.
  void updateAddress(String address) {
    emit(state.copyWith(address: address, clearError: true));
  }

  /// Updates the active status.
  void updateIsActive(bool isActive) {
    emit(state.copyWith(isActive: isActive, clearError: true));
  }

  /// Looks up guardian by email.
  Future<void> lookupGuardianByEmail(String email) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      emit(
        state.copyWith(
          error: 'Please enter a valid email address',
          status: AddGuardianStatus.lookupFailure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AddGuardianStatus.lookingUp,
        email: email,
        clearError: true,
      ),
    );

    try {
      final response = await _guardiansRepository.lookupGuardianByEmail(email);

      if (response.found && response.guardian != null) {
        // Guardian exists - populate form with their details
        emit(
          state.copyWith(
            status: AddGuardianStatus.lookupSuccess,
            existingGuardian: response.guardian,
            isExistingGuardian: true,
            fullName:
                '${response.guardian!.firstName ?? ''} ${response.guardian!.lastName ?? ''}',

            phone: response.guardian!.phone ?? '',
            address: response.guardian!.address ?? '',
            isEditable: false,
            successMessage: 'Success! Guardian details have been fetched.',
          ),
        );
      } else {
        // Guardian not found - allow creating new
        emit(
          state.copyWith(
            status: AddGuardianStatus.lookupNotFound,
            isExistingGuardian: false,
            isEditable: true,
            clearExistingGuardian: true,
            successMessage:
                'No existing guardian found. You can create a new one.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AddGuardianStatus.lookupFailure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Searches for students to link.
  Future<List<LinkedStudentModel>> searchStudents(String query) async {
    if (query.isEmpty) return [];

    try {
      return await _guardiansRepository.searchStudentsForLinking(query);
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to search students: ${_getErrorMessage(e)}',
        ),
      );
      return [];
    }
  }

  /// Adds a student to linked students list.
  void addLinkedStudent(LinkedStudentModel student) {
    // Check if student is already linked
    if (state.linkedStudents.any((s) => s.id == student.id)) {
      emit(state.copyWith(error: '${student.name} is already linked'));
      return;
    }

    emit(
      state.copyWith(
        linkedStudents: [...state.linkedStudents, student],
        clearError: true,
      ),
    );
  }

  /// Updates the relation for a linked student.
  void updateStudentRelation(String studentId, String relation) {
    final updatedStudents = state.linkedStudents.map((student) {
      if (student.id == studentId) {
        return student.copyWith(relation: relation);
      }
      return student;
    }).toList();

    emit(state.copyWith(linkedStudents: updatedStudents, clearError: true));
  }

  /// Removes a student from linked students list.
  void removeLinkedStudent(String studentId) {
    emit(
      state.copyWith(
        linkedStudents: state.linkedStudents
            .where((s) => s.id != studentId)
            .toList(),
        clearError: true,
      ),
    );
  }

  /// Clears all linked students.
  void clearLinkedStudents() {
    emit(state.copyWith(linkedStudents: [], clearError: true));
  }

  /// Submits the form to create/link guardian.
  Future<void> submitForm() async {
    if (!state.canSubmit) {
      // Check for specific missing fields
      if (state.linkedStudents.isEmpty) {
        emit(state.copyWith(error: 'Please link at least one student'));
        return;
      }
      if (state.linkedStudents.any((s) => s.relation.isEmpty)) {
        emit(
          state.copyWith(
            error: 'Please specify relation for all linked students',
          ),
        );
        return;
      }
      emit(state.copyWith(error: 'Please fill in all required fields'));
      return;
    }

    emit(
      state.copyWith(status: AddGuardianStatus.submitting, clearError: true),
    );

    try {
      final relations = state.linkedStudents.map((student) {
        return StudentRelation(
          studentId: student.id,
          relation: student.relation,
        );
      }).toList();

      GuardianModel resultGuardian;

      if (state.isEditMode && state.guardianId != null) {
        // Update existing guardian
        final request = UpdateGuardianRequest(
          email: state.email,
          firstName: state.fullName,
          lastName: state.lastName,
          phone: state.phone,
          address: state.address,
          schoolId: state.schoolId,
          relations: relations,
          isActive: state.isActive,
        );

        resultGuardian = await _guardiansRepository.updateGuardian(
          state.guardianId!,
          request,
        );

        emit(
          state.copyWith(
            status: AddGuardianStatus.success,
            createdGuardian: resultGuardian,
            successMessage: 'Guardian updated successfully',
          ),
        );
      } else {
        // Create new guardian
        final request = CreateGuardianRequest(
          email: state.email,
          firstName: state.fullName,
          lastName: state.lastName,
          phone: state.phone,
          address: state.address,
          schoolId: state.schoolId,
          relations: relations,
          isActive: state.isActive,
        );

        resultGuardian = await _guardiansRepository.createGuardian(request);

        emit(
          state.copyWith(
            status: AddGuardianStatus.success,
            createdGuardian: resultGuardian,
            successMessage: 'Guardian added successfully',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AddGuardianStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Deletes the guardian.
  Future<void> deleteGuardian() async {
    if (!state.isEditMode || state.guardianId == null) {
      emit(state.copyWith(error: 'Cannot delete: No guardian selected'));
      return;
    }

    emit(
      state.copyWith(status: AddGuardianStatus.submitting, clearError: true),
    );

    try {
      await _guardiansRepository.deleteGuardian(state.guardianId!);

      emit(
        state.copyWith(
          status: AddGuardianStatus.deleteSuccess,
          successMessage: 'Guardian deleted successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddGuardianStatus.deleteFailure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Resets the form to initial state.
  void resetForm() {
    emit(AddGuardianState(schoolId: state.schoolId));
  }

  /// Clears error message.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Clears success message.
  void clearSuccess() {
    emit(state.copyWith(clearSuccess: true));
  }

  /// Enables editing mode.
  void enableEditing() {
    emit(state.copyWith(isEditable: true));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
