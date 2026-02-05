import 'dart:io';

import 'package:equatable/equatable.dart';

/// Enum for the current step in the create student flow.
enum CreateStudentStep { personalInfo, documents, parentInfo, photo }

/// Enum for the submission status.
enum SubmissionStatus { initial, loading, success, failure }

/// Model for a document with name and file.
class DocumentModel extends Equatable {
  const DocumentModel({required this.name, this.file});

  final String name;
  final File? file;

  DocumentModel copyWith({String? name, File? file}) {
    return DocumentModel(name: name ?? this.name, file: file ?? this.file);
  }

  bool get hasFile => file != null;

  String get fileName => file?.path.split('/').last ?? '';

  @override
  List<Object?> get props => [name, file?.path];
}

/// Immutable state class for CreateStudentCubit.
class CreateStudentState extends Equatable {
  const CreateStudentState({
    this.currentStep = CreateStudentStep.personalInfo,
    this.isInitialLoading = true,
    this.submissionStatus = SubmissionStatus.initial,
    this.errorMessage,
    // Step 1: Personal Info
    this.fullName = '',
    this.selectedClass,
    this.selectedAcademicYear,
    this.roleNumber = '',
    this.dateOfBirth,
    this.selectedGender,
    this.selectedBloodGroup,
    this.address = '',
    this.email = '',
    this.studentId = '',
    // Step 2: Documents
    this.documents = const [],
    // Step 3: Parent Info
    this.parentFullName = '',
    this.parentEmail = '',
    this.parentContactNo = '',
    this.parentAddress = '',
    // Step 4: Photo
    this.photo,
    // Dropdown data (fetched from API)
    this.classes = const [],
    this.genders = const [],
    this.bloodGroups = const [],
    this.academicYears = const [],
  });

  // Flow state
  final CreateStudentStep currentStep;
  final bool isInitialLoading;
  final SubmissionStatus submissionStatus;
  final String? errorMessage;

  // Step 1: Personal Info
  final String fullName;
  final String? selectedClass;
  final String roleNumber;
  final DateTime? dateOfBirth;
  final String? selectedAcademicYear;
  final String? selectedGender;
  final String? selectedBloodGroup;
  final String address;
  final String email;
  final String studentId;

  // Step 2: Documents
  final List<DocumentModel> documents;

  // Step 3: Parent Info
  final String parentFullName;
  final String parentEmail;
  final String parentContactNo;
  final String parentAddress;

  // Step 4: Photo
  final File? photo;

  // Dropdown data (fetched from API)
  final List<String> classes;
  final List<String> genders;
  final List<String> bloodGroups;
  final List<String> academicYears;

  /// Helper getters
  bool get isSubmitting => submissionStatus == SubmissionStatus.loading;
  bool get isSuccess => submissionStatus == SubmissionStatus.success;
  bool get isFailure => submissionStatus == SubmissionStatus.failure;

  int get currentStepIndex => currentStep.index;
  int get totalSteps => CreateStudentStep.values.length;

  bool get isFirstStep => currentStep == CreateStudentStep.personalInfo;
  bool get isLastStep => currentStep == CreateStudentStep.photo;

  /// Get student name for display
  String get displayName => fullName.isNotEmpty ? fullName : 'Student';

  /// Check if photo is selected
  bool get hasPhoto => photo != null;

  /// Formatted date of birth
  String get formattedDateOfBirth {
    if (dateOfBirth == null) return '';
    return '${dateOfBirth!.day.toString().padLeft(2, '0')}/'
        '${dateOfBirth!.month.toString().padLeft(2, '0')}/'
        '${dateOfBirth!.year}';
  }

  CreateStudentState copyWith({
    CreateStudentStep? currentStep,
    bool? isInitialLoading,
    SubmissionStatus? submissionStatus,
    String? errorMessage,
    // Step 1
    String? fullName,
    String? selectedClass,
    String? selectedDivision,
    String? selectedAcademicYear,
    String? roleNumber,
    DateTime? dateOfBirth,
    String? selectedGender,
    String? selectedBloodGroup,
    String? address,
    String? email,
    String? studentId,
    // Step 2
    List<DocumentModel>? documents,
    // Step 3
    String? parentFullName,
    String? parentEmail,
    String? parentContactNo,
    String? parentAddress,
    // Step 4
    File? photo,
    bool clearPhoto = false,
    // Dropdown data
    List<String>? classes,
    List<String>? divisions,
    List<String>? genders,
    List<String>? bloodGroups,
    List<String>? academicYears,
  }) {
    return CreateStudentState(
      currentStep: currentStep ?? this.currentStep,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage,
      // Step 1
      fullName: fullName ?? this.fullName,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedAcademicYear: selectedAcademicYear ?? this.selectedAcademicYear,
      roleNumber: roleNumber ?? this.roleNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedBloodGroup: selectedBloodGroup ?? this.selectedBloodGroup,
      address: address ?? this.address,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      // Step 2
      documents: documents ?? this.documents,
      // Step 3
      parentFullName: parentFullName ?? this.parentFullName,
      parentEmail: parentEmail ?? this.parentEmail,
      parentContactNo: parentContactNo ?? this.parentContactNo,
      parentAddress: parentAddress ?? this.parentAddress,
      // Step 4
      photo: clearPhoto ? null : (photo ?? this.photo),
      // Dropdown data
      classes: classes ?? this.classes,
      genders: genders ?? this.genders,
      bloodGroups: bloodGroups ?? this.bloodGroups,
      academicYears: academicYears ?? this.academicYears,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isInitialLoading,
    submissionStatus,
    errorMessage,
    fullName,
    selectedClass,
    selectedAcademicYear,
    roleNumber,
    dateOfBirth,
    selectedGender,
    selectedBloodGroup,
    address,
    email,
    studentId,
    documents,
    parentFullName,
    parentEmail,
    parentContactNo,
    parentAddress,
    photo?.path,
    classes,
    genders,
    bloodGroups,
    academicYears,
  ];
}
