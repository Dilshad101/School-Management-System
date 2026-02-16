import 'package:equatable/equatable.dart';

import '../../models/guardian_model.dart';
import '../../models/create_guardian_request.dart';

/// Enum representing the status of add guardian operations.
enum AddGuardianStatus {
  initial,
  lookingUp,
  lookupSuccess,
  lookupNotFound,
  lookupFailure,
  searchingStudents,
  loading, // For loading guardian details in edit mode
  submitting,
  success,
  failure,
  deleteSuccess,
  deleteFailure,
}

/// State class for add guardian feature.
class AddGuardianState extends Equatable {
  const AddGuardianState({
    this.status = AddGuardianStatus.initial,
    this.email = '',
    this.fullName = '',
    this.lastName = '',
    this.phone = '',
    this.address = '',
    this.schoolId = '',
    this.linkedStudents = const [],
    this.existingGuardian,
    this.isExistingGuardian = false,
    this.createdGuardian,
    this.error,
    this.successMessage,
    this.isFormValid = false,
    this.isEditable = true,
    this.isEditMode = false,
    this.guardianId,
    this.isActive = true,
  });

  final AddGuardianStatus status;
  final String email;
  final String fullName;
  final String lastName;
  final String phone;
  final String address;
  final String schoolId;
  final List<LinkedStudentModel> linkedStudents;
  final GuardianLookupData? existingGuardian;
  final bool isExistingGuardian;
  final GuardianModel? createdGuardian;
  final String? error;
  final String? successMessage;
  final bool isFormValid;
  final bool isEditable;
  final bool isEditMode;
  final String? guardianId;
  final bool isActive;

  /// Check if loading guardian details.
  bool get isLoading => status == AddGuardianStatus.loading;

  /// Check if lookup is in progress.
  bool get isLookingUp => status == AddGuardianStatus.lookingUp;

  /// Check if submitting.
  bool get isSubmitting => status == AddGuardianStatus.submitting;

  /// Check if guardian was successfully created/updated.
  bool get isSuccess => status == AddGuardianStatus.success;

  /// Check if delete was successful.
  bool get isDeleteSuccess => status == AddGuardianStatus.deleteSuccess;

  /// Check if there's an error.
  bool get hasError =>
      status == AddGuardianStatus.failure ||
      status == AddGuardianStatus.lookupFailure ||
      status == AddGuardianStatus.deleteFailure;

  /// Check if lookup was successful (guardian found).
  bool get isLookupSuccess => status == AddGuardianStatus.lookupSuccess;

  /// Check if lookup found no guardian.
  bool get isLookupNotFound => status == AddGuardianStatus.lookupNotFound;

  /// Check if searching students.
  bool get isSearchingStudents => status == AddGuardianStatus.searchingStudents;

  /// Check if form can be submitted.
  bool get canSubmit =>
      email.isNotEmpty &&
      fullName.isNotEmpty &&
      phone.isNotEmpty &&
      linkedStudents.isNotEmpty &&
      linkedStudents.every((s) => s.relation.isNotEmpty) &&
      !isSubmitting &&
      !isLookingUp &&
      !isLoading;

  AddGuardianState copyWith({
    AddGuardianStatus? status,
    String? email,
    String? fullName,
    String? lastName,
    String? phone,
    String? address,
    String? schoolId,
    List<LinkedStudentModel>? linkedStudents,
    GuardianLookupData? existingGuardian,
    bool? isExistingGuardian,
    GuardianModel? createdGuardian,
    String? error,
    String? successMessage,
    bool? isFormValid,
    bool? isEditable,
    bool? isEditMode,
    String? guardianId,
    bool? isActive,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearExistingGuardian = false,
  }) {
    return AddGuardianState(
      status: status ?? this.status,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      schoolId: schoolId ?? this.schoolId,
      linkedStudents: linkedStudents ?? this.linkedStudents,
      existingGuardian: clearExistingGuardian
          ? null
          : (existingGuardian ?? this.existingGuardian),
      isExistingGuardian: isExistingGuardian ?? this.isExistingGuardian,
      createdGuardian: createdGuardian ?? this.createdGuardian,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      isFormValid: isFormValid ?? this.isFormValid,
      isEditable: isEditable ?? this.isEditable,
      isEditMode: isEditMode ?? this.isEditMode,
      guardianId: guardianId ?? this.guardianId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    fullName,
    lastName,
    phone,
    address,
    schoolId,
    linkedStudents,
    existingGuardian,
    isExistingGuardian,
    createdGuardian,
    error,
    successMessage,
    isFormValid,
    isEditable,
    isEditMode,
    guardianId,
    isActive,
  ];
}
