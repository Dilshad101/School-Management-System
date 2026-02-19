import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../models/role_model.dart';
import '../../models/subject_model.dart';

export '../../models/role_model.dart';
export '../../models/subject_model.dart';

/// Enum for the current step in the create employee flow.
enum CreateEmployeeStep { personalInfo, documents, photo }

/// Enum for the submission status.
enum SubmissionStatus { initial, loading, success, failure }

/// Model for a document with name and file.
class EmployeeDocumentModel extends Equatable {
  const EmployeeDocumentModel({
    required this.id,
    required this.name,
    this.file,
    this.existingUrl,
    this.isExisting = false,
  });

  final String id;
  final String name;
  final File? file;
  final String? existingUrl;
  final bool isExisting;

  EmployeeDocumentModel copyWith({
    String? id,
    String? name,
    File? file,
    String? existingUrl,
    bool? isExisting,
  }) {
    return EmployeeDocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      file: file ?? this.file,
      existingUrl: existingUrl ?? this.existingUrl,
      isExisting: isExisting ?? this.isExisting,
    );
  }

  bool get hasFile => file != null || existingUrl != null;

  String get fileName => file?.path.split('/').last ?? '';

  @override
  List<Object?> get props => [id, name, file?.path, existingUrl, isExisting];
}

/// Immutable state class for CreateEmployeeCubit.
class CreateEmployeeState extends Equatable {
  const CreateEmployeeState({
    this.currentStep = CreateEmployeeStep.personalInfo,
    this.isInitialLoading = true,
    this.submissionStatus = SubmissionStatus.initial,
    this.errorMessage,
    // Step 1: Personal Info
    this.selectedRoles = const [],
    this.fullName = '',
    this.mobileNo = '',
    this.joiningDate,
    this.selectedSubjects = const [],
    this.selectedGender,
    this.selectedBloodGroup,
    this.address = '',
    this.email = '',
    this.employeeId = '',
    // Step 2: Documents
    this.documents = const [],
    // Step 3: Photo
    this.photo,
    this.existingProfilePicUrl,
    // Dropdown data (fetched from API)
    this.roles = const [],
    this.subjects = const [],
    this.genders = const [],
    this.bloodGroups = const [],
    // Edit mode
    this.isEditMode = false,
    this.editingEmployeeId,
    this.deletedDocumentIds = const [],
  });

  // Flow state
  final CreateEmployeeStep currentStep;
  final bool isInitialLoading;
  final SubmissionStatus submissionStatus;
  final String? errorMessage;

  // Step 1: Personal Info
  final List<RoleModel> selectedRoles;
  final String fullName;
  final String mobileNo;
  final DateTime? joiningDate;
  final List<SubjectModel> selectedSubjects;
  final String? selectedGender;
  final String? selectedBloodGroup;
  final String address;
  final String email;
  final String employeeId;

  // Step 2: Documents
  final List<EmployeeDocumentModel> documents;

  // Step 3: Photo
  final File? photo;
  final String? existingProfilePicUrl;

  // Dropdown data (fetched from API)
  final List<RoleModel> roles;
  final List<SubjectModel> subjects;
  final List<String> genders;
  final List<String> bloodGroups;

  // Edit mode
  final bool isEditMode;
  final String? editingEmployeeId;
  final List<String> deletedDocumentIds;

  /// Helper getters
  bool get isSubmitting => submissionStatus == SubmissionStatus.loading;
  bool get isSuccess => submissionStatus == SubmissionStatus.success;
  bool get isFailure => submissionStatus == SubmissionStatus.failure;

  int get currentStepIndex => currentStep.index;
  int get totalSteps => CreateEmployeeStep.values.length;

  bool get isFirstStep => currentStep == CreateEmployeeStep.personalInfo;
  bool get isLastStep => currentStep == CreateEmployeeStep.photo;

  bool get hasRolesSelected => selectedRoles.isNotEmpty;

  /// Get employee name for display
  String get displayName => fullName.isNotEmpty ? fullName : 'Employee';

  /// Check if photo is selected (either new or existing)
  bool get hasPhoto => photo != null || existingProfilePicUrl != null;

  /// Check if has new photo selected
  bool get hasNewPhoto => photo != null;

  /// Get primary role label (first selected role)
  String get primaryRoleLabel =>
      selectedRoles.isNotEmpty ? selectedRoles.first.name : 'Select Role';

  /// Formatted joining date
  String get formattedJoiningDate {
    if (joiningDate == null) return '';
    return '${joiningDate!.day.toString().padLeft(2, '0')}/'
        '${joiningDate!.month.toString().padLeft(2, '0')}/'
        '${joiningDate!.year}';
  }

  CreateEmployeeState copyWith({
    CreateEmployeeStep? currentStep,
    bool? isInitialLoading,
    SubmissionStatus? submissionStatus,
    String? errorMessage,
    // Step 1
    List<RoleModel>? selectedRoles,
    String? fullName,
    String? mobileNo,
    DateTime? joiningDate,
    List<SubjectModel>? selectedSubjects,
    String? selectedGender,
    String? selectedBloodGroup,
    String? address,
    String? email,
    String? employeeId,
    // Step 2
    List<EmployeeDocumentModel>? documents,
    // Step 3
    File? photo,
    bool clearPhoto = false,
    String? existingProfilePicUrl,
    bool clearExistingPhoto = false,
    // Dropdown data
    List<RoleModel>? roles,
    List<SubjectModel>? subjects,
    List<String>? genders,
    List<String>? bloodGroups,
    // Edit mode
    bool? isEditMode,
    String? editingEmployeeId,
    List<String>? deletedDocumentIds,
  }) {
    return CreateEmployeeState(
      currentStep: currentStep ?? this.currentStep,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage,
      // Step 1
      selectedRoles: selectedRoles ?? this.selectedRoles,
      fullName: fullName ?? this.fullName,
      mobileNo: mobileNo ?? this.mobileNo,
      joiningDate: joiningDate ?? this.joiningDate,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedBloodGroup: selectedBloodGroup ?? this.selectedBloodGroup,
      address: address ?? this.address,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      // Step 2
      documents: documents ?? this.documents,
      // Step 3
      photo: clearPhoto ? null : (photo ?? this.photo),
      existingProfilePicUrl: clearExistingPhoto
          ? null
          : (existingProfilePicUrl ?? this.existingProfilePicUrl),
      // Dropdown data
      roles: roles ?? this.roles,
      subjects: subjects ?? this.subjects,
      genders: genders ?? this.genders,
      bloodGroups: bloodGroups ?? this.bloodGroups,
      // Edit mode
      isEditMode: isEditMode ?? this.isEditMode,
      editingEmployeeId: editingEmployeeId ?? this.editingEmployeeId,
      deletedDocumentIds: deletedDocumentIds ?? this.deletedDocumentIds,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isInitialLoading,
    submissionStatus,
    errorMessage,
    selectedRoles,
    fullName,
    mobileNo,
    joiningDate,
    selectedSubjects,
    selectedGender,
    selectedBloodGroup,
    address,
    email,
    employeeId,
    documents,
    photo,
    existingProfilePicUrl,
    roles,
    subjects,
    genders,
    bloodGroups,
    isEditMode,
    editingEmployeeId,
    deletedDocumentIds,
  ];
}
