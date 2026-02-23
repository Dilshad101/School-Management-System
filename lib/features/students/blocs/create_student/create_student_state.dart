import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../models/academic_year_model.dart';
import '../../models/class_room_model.dart';
import '../../models/student_document_model.dart';

/// Enum for the current step in the create student flow.
enum CreateStudentStep { personalInfo, documents, parentInfo, photo }

/// Enum for the submission status.
enum SubmissionStatus { initial, loading, success, failure }

/// Enum to track the form mode.
enum StudentFormMode { create, edit }

/// Model for a document with name and file.
class DocumentModel extends Equatable {
  const DocumentModel({
    required this.name,
    this.file,
    this.existingUrl,
    this.existingId,
  });

  final String name;
  final File? file;
  final String? existingUrl;
  final int? existingId;

  DocumentModel copyWith({
    String? name,
    File? file,
    String? existingUrl,
    int? existingId,
    bool clearFile = false,
  }) {
    return DocumentModel(
      name: name ?? this.name,
      file: clearFile ? null : (file ?? this.file),
      existingUrl: existingUrl ?? this.existingUrl,
      existingId: existingId ?? this.existingId,
    );
  }

  bool get hasFile => file != null;
  bool get hasExistingFile => existingUrl != null;
  bool get hasAnyFile => hasFile || hasExistingFile;

  String get fileName => file?.path.split('/').last ?? '';

  /// Creates DocumentModel from API response.
  factory DocumentModel.fromApiDocument(StudentDocumentModel doc) {
    return DocumentModel(
      name: doc.documentName ?? 'Document',
      existingUrl: doc.documentFile,
      existingId: doc.id,
    );
  }

  @override
  List<Object?> get props => [name, file?.path, existingUrl, existingId];
}

/// Immutable state class for CreateStudentCubit.
class CreateStudentState extends Equatable {
  const CreateStudentState({
    this.formMode = StudentFormMode.create,
    this.editingStudentId,
    this.currentStep = CreateStudentStep.personalInfo,
    this.isInitialLoading = true,
    this.isLoadingStudentDetails = false,
    this.submissionStatus = SubmissionStatus.initial,
    this.errorMessage,
    // Step 1: Personal Info
    this.fullName = '',
    this.selectedClassRoom,
    this.selectedAcademicYear,
    this.roleNumber = '',
    this.dateOfBirth,
    this.selectedGender,
    this.selectedBloodGroup,
    this.address = '',
    this.email = '',
    this.phone = '',
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
    this.existingPhotoUrl,
    // Dropdown data (fetched from API)
    this.classRooms = const [],
    this.genders = const [],
    this.bloodGroups = const [],
    this.academicYears = const [],
    // School ID for submission
    this.schoolId,
  });

  // Form mode
  final StudentFormMode formMode;
  final String? editingStudentId;

  // Flow state
  final CreateStudentStep currentStep;
  final bool isInitialLoading;
  final bool isLoadingStudentDetails;
  final SubmissionStatus submissionStatus;
  final String? errorMessage;

  // Step 1: Personal Info
  final String fullName;
  final ClassRoomModel? selectedClassRoom;
  final String roleNumber;
  final DateTime? dateOfBirth;
  final AcademicYearModel? selectedAcademicYear;
  final String? selectedGender;
  final String? selectedBloodGroup;
  final String address;
  final String email;
  final String phone;
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
  final String? existingPhotoUrl;

  // Dropdown data (fetched from API)
  final List<ClassRoomModel> classRooms;
  final List<String> genders;
  final List<String> bloodGroups;
  final List<AcademicYearModel> academicYears;

  // School ID
  final String? schoolId;

  /// Helper getters
  bool get isEditMode => formMode == StudentFormMode.edit;
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
  bool get hasPhoto => photo != null || existingPhotoUrl != null;

  /// Formatted date of birth
  String get formattedDateOfBirth {
    if (dateOfBirth == null) return '';
    return '${dateOfBirth!.day.toString().padLeft(2, '0')}/'
        '${dateOfBirth!.month.toString().padLeft(2, '0')}/'
        '${dateOfBirth!.year}';
  }

  CreateStudentState copyWith({
    StudentFormMode? formMode,
    String? editingStudentId,
    bool clearEditingStudentId = false,
    CreateStudentStep? currentStep,
    bool? isInitialLoading,
    bool? isLoadingStudentDetails,
    SubmissionStatus? submissionStatus,
    String? errorMessage,
    // Step 1
    String? fullName,
    ClassRoomModel? selectedClassRoom,
    bool clearSelectedClassRoom = false,
    AcademicYearModel? selectedAcademicYear,
    bool clearSelectedAcademicYear = false,
    String? roleNumber,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    String? selectedGender,
    bool clearSelectedGender = false,
    String? selectedBloodGroup,
    bool clearSelectedBloodGroup = false,
    String? address,
    String? email,
    String? phone,
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
    String? existingPhotoUrl,
    bool clearExistingPhotoUrl = false,
    // Dropdown data
    List<ClassRoomModel>? classRooms,
    List<String>? genders,
    List<String>? bloodGroups,
    List<AcademicYearModel>? academicYears,
    // School ID
    String? schoolId,
  }) {
    return CreateStudentState(
      formMode: formMode ?? this.formMode,
      editingStudentId: clearEditingStudentId
          ? null
          : (editingStudentId ?? this.editingStudentId),
      currentStep: currentStep ?? this.currentStep,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingStudentDetails:
          isLoadingStudentDetails ?? this.isLoadingStudentDetails,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage,
      // Step 1
      fullName: fullName ?? this.fullName,
      selectedClassRoom: clearSelectedClassRoom
          ? null
          : (selectedClassRoom ?? this.selectedClassRoom),
      selectedAcademicYear: clearSelectedAcademicYear
          ? null
          : (selectedAcademicYear ?? this.selectedAcademicYear),
      roleNumber: roleNumber ?? this.roleNumber,
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      selectedGender: clearSelectedGender
          ? null
          : (selectedGender ?? this.selectedGender),
      selectedBloodGroup: clearSelectedBloodGroup
          ? null
          : (selectedBloodGroup ?? this.selectedBloodGroup),
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
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
      existingPhotoUrl: clearExistingPhotoUrl
          ? null
          : (existingPhotoUrl ?? this.existingPhotoUrl),
      // Dropdown data
      classRooms: classRooms ?? this.classRooms,
      genders: genders ?? this.genders,
      bloodGroups: bloodGroups ?? this.bloodGroups,
      academicYears: academicYears ?? this.academicYears,
      // School ID
      schoolId: schoolId ?? this.schoolId,
    );
  }

  @override
  List<Object?> get props => [
    formMode,
    editingStudentId,
    currentStep,
    isInitialLoading,
    isLoadingStudentDetails,
    submissionStatus,
    errorMessage,
    fullName,
    selectedClassRoom,
    selectedAcademicYear,
    roleNumber,
    dateOfBirth,
    selectedGender,
    selectedBloodGroup,
    address,
    email,
    phone,
    studentId,
    documents,
    parentFullName,
    parentEmail,
    parentContactNo,
    parentAddress,
    photo?.path,
    existingPhotoUrl,
    classRooms,
    genders,
    bloodGroups,
    academicYears,
    schoolId,
  ];
}
