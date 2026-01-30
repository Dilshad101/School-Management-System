import 'dart:io';

import 'package:equatable/equatable.dart';

/// Enum for staff categories.
enum StaffCategory {
  teachers('Teachers'),
  officeStaff('Office Staff'),
  hostelWarden('Hostel Warden'),
  securityStaff('Security Staff');

  const StaffCategory(this.label);
  final String label;
}

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
  });

  final String id;
  final String name;
  final File? file;

  EmployeeDocumentModel copyWith({String? id, String? name, File? file}) {
    return EmployeeDocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      file: file ?? this.file,
    );
  }

  bool get hasFile => file != null;

  String get fileName => file?.path.split('/').last ?? '';

  @override
  List<Object?> get props => [id, name, file?.path];
}

/// Model for a staff category.
class StaffCategoryModel extends Equatable {
  const StaffCategoryModel({
    required this.id,
    required this.name,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final bool isCustom;

  @override
  List<Object?> get props => [id, name, isCustom];
}

/// Immutable state class for CreateEmployeeCubit.
class CreateEmployeeState extends Equatable {
  const CreateEmployeeState({
    this.currentStep = CreateEmployeeStep.personalInfo,
    this.isInitialLoading = true,
    this.submissionStatus = SubmissionStatus.initial,
    this.errorMessage,
    // Staff category selection
    this.selectedStaffCategory,
    // Step 1: Personal Info
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
    // Dropdown data (fetched from API)
    this.subjects = const [],
    this.genders = const [],
    this.bloodGroups = const [],
  });

  // Flow state
  final CreateEmployeeStep currentStep;
  final bool isInitialLoading;
  final SubmissionStatus submissionStatus;
  final String? errorMessage;

  // Staff category selection
  final StaffCategoryModel? selectedStaffCategory;

  // Step 1: Personal Info
  final String fullName;
  final String mobileNo;
  final DateTime? joiningDate;
  final List<String> selectedSubjects;
  final String? selectedGender;
  final String? selectedBloodGroup;
  final String address;
  final String email;
  final String employeeId;

  // Step 2: Documents
  final List<EmployeeDocumentModel> documents;

  // Step 3: Photo
  final File? photo;

  // Dropdown data (fetched from API)
  final List<String> subjects;
  final List<String> genders;
  final List<String> bloodGroups;

  /// Helper getters
  bool get isSubmitting => submissionStatus == SubmissionStatus.loading;
  bool get isSuccess => submissionStatus == SubmissionStatus.success;
  bool get isFailure => submissionStatus == SubmissionStatus.failure;

  int get currentStepIndex => currentStep.index;
  int get totalSteps => CreateEmployeeStep.values.length;

  bool get isFirstStep => currentStep == CreateEmployeeStep.personalInfo;
  bool get isLastStep => currentStep == CreateEmployeeStep.photo;

  bool get hasCategorySelected => selectedStaffCategory != null;

  /// Get employee name for display
  String get displayName => fullName.isNotEmpty ? fullName : 'Employee';

  /// Check if photo is selected
  bool get hasPhoto => photo != null;

  /// Get category label
  String get categoryLabel => selectedStaffCategory?.name ?? 'Select Category';

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
    // Staff category
    StaffCategoryModel? selectedStaffCategory,
    // Step 1
    String? fullName,
    String? mobileNo,
    DateTime? joiningDate,
    List<String>? selectedSubjects,
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
    // Dropdown data
    List<String>? subjects,
    List<String>? genders,
    List<String>? bloodGroups,
  }) {
    return CreateEmployeeState(
      currentStep: currentStep ?? this.currentStep,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage,
      // Staff category
      selectedStaffCategory:
          selectedStaffCategory ?? this.selectedStaffCategory,
      // Step 1
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
      // Dropdown data
      subjects: subjects ?? this.subjects,
      genders: genders ?? this.genders,
      bloodGroups: bloodGroups ?? this.bloodGroups,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isInitialLoading,
    submissionStatus,
    errorMessage,
    selectedStaffCategory,
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
    subjects,
    genders,
    bloodGroups,
  ];
}
