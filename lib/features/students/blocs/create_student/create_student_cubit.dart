import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/di.dart';
import '../../models/academic_year_model.dart';
import '../../models/class_room_model.dart';
import '../../models/create_student_request.dart';
import '../../models/student_document_model.dart';
import '../../models/student_model.dart';
import '../../repositories/students_repository.dart';
import 'create_student_state.dart';

export 'create_student_state.dart';

/// Cubit for managing the Create/Edit Student flow state.
class CreateStudentCubit extends Cubit<CreateStudentState> {
  CreateStudentCubit({StudentsRepository? studentsRepository})
    : _studentsRepository = studentsRepository ?? locator<StudentsRepository>(),
      super(const CreateStudentState());

  final StudentsRepository _studentsRepository;
  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize for creating a new student.
  Future<void> initialize() async {
    emit(
      state.copyWith(isInitialLoading: true, formMode: StudentFormMode.create),
    );

    try {
      // Fetch dropdown data in parallel
      final results = await Future.wait([
        _studentsRepository.getClassRooms(),
        _studentsRepository.getAcademicYears(),
      ]);

      final classRoomsResponse = results[0] as ClassRoomListResponse;
      final academicYearsResponse = results[1] as AcademicYearListResponse;

      // Generate auto student ID
      final studentId = _generateStudentId();

      // Get school ID from session
      final schoolId = _getSchoolId();

      emit(
        state.copyWith(
          isInitialLoading: false,
          classRooms: classRoomsResponse.results,
          academicYears: academicYearsResponse.results,
          genders: _getGenders(),
          bloodGroups: _getBloodGroups(),
          studentId: studentId,
          documents: [],
          schoolId: schoolId,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isInitialLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load data. Please try again.',
        ),
      );
    }
  }

  /// Initialize for editing an existing student.
  Future<void> initializeForEdit(String studentId) async {
    emit(
      state.copyWith(
        isInitialLoading: true,
        formMode: StudentFormMode.edit,
        editingStudentId: studentId,
      ),
    );

    try {
      // Fetch dropdown data and student details in parallel
      final results = await Future.wait([
        _studentsRepository.getClassRooms(),
        _studentsRepository.getAcademicYears(),
        _studentsRepository.getStudentById(studentId),
      ]);

      final classRoomsResponse = results[0] as ClassRoomListResponse;
      final academicYearsResponse = results[1] as AcademicYearListResponse;
      final student = results[2] as StudentModel;

      // Get school ID from session
      final schoolId = _getSchoolId();

      // Parse date of birth
      DateTime? dateOfBirth;
      if (student.profile?.dateOfBirth != null) {
        dateOfBirth = DateTime.tryParse(student.profile!.dateOfBirth!);
      }

      // Convert documents from API to DocumentModel
      final documents = _convertApiDocuments(student.documents);

      // Find matching classroom from dropdown list
      ClassRoomModel? selectedClassRoom;
      if (student.enrollment?.classroomId != null &&
          classRoomsResponse.results.isNotEmpty) {
        try {
          selectedClassRoom = classRoomsResponse.results.firstWhere(
            (c) => c.id == student.enrollment!.classroomId,
          );
        } catch (_) {
          // No matching classroom found
          selectedClassRoom = null;
        }
      }

      // Find matching academic year from dropdown list
      AcademicYearModel? selectedAcademicYear;
      if (student.enrollment?.academicYearId != null &&
          academicYearsResponse.results.isNotEmpty) {
        try {
          selectedAcademicYear = academicYearsResponse.results.firstWhere(
            (a) => a.id == student.enrollment!.academicYearId,
          );
        } catch (_) {
          // No matching academic year found
          selectedAcademicYear = null;
        }
      }

      emit(
        state.copyWith(
          isInitialLoading: false,
          classRooms: classRoomsResponse.results,
          academicYears: academicYearsResponse.results,
          genders: _getGenders(),
          bloodGroups: _getBloodGroups(),
          schoolId: schoolId,
          // Populate form with student data
          fullName: student.firstName ?? '',
          email: student.email,
          phone: student.phone ?? '',
          address: student.profile?.address ?? '',
          dateOfBirth: dateOfBirth,
          selectedGender: student.profile?.gender,
          selectedBloodGroup: student.profile?.bloodGroup,
          existingPhotoUrl: student.profile?.profilePic,
          documents: documents,
          // Student ID for display purposes
          studentId: 'STU${student.id}',
          // Enrollment data
          selectedClassRoom: selectedClassRoom,
          selectedAcademicYear: selectedAcademicYear,
          roleNumber: student.enrollment?.rollNo ?? '',
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isInitialLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load student data. Please try again.',
        ),
      );
    }
  }

  /// Convert API documents to DocumentModel list.
  List<DocumentModel> _convertApiDocuments(List<dynamic> apiDocuments) {
    return apiDocuments.map((doc) {
      if (doc is Map<String, dynamic>) {
        return DocumentModel.fromApiDocument(
          StudentDocumentModel.fromJson(doc),
        );
      }
      return const DocumentModel(name: 'Document');
    }).toList();
  }

  /// Get school ID from session holder.
  String? _getSchoolId() {
    try {
      final sessionHolder = locator<SessionHolder>();
      return sessionHolder.session?.schoolId;
    } catch (e) {
      return null;
    }
  }

  /// Static list of genders.
  List<String> _getGenders() => ['Male', 'Female', 'Other'];

  /// Static list of blood groups.
  List<String> _getBloodGroups() => [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  /// Generates a unique student ID.
  String _generateStudentId() {
    final year = DateTime.now().year;
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'STU$year${random.toString().padLeft(4, '0')}';
  }

  // ==================== Step Navigation ====================

  /// Move to the next step.
  void goToNextStep() {
    final currentIndex = state.currentStep.index;
    if (currentIndex < CreateStudentStep.values.length - 1) {
      emit(
        state.copyWith(currentStep: CreateStudentStep.values[currentIndex + 1]),
      );
    }
  }

  /// Move to the previous step.
  void goToPreviousStep() {
    final currentIndex = state.currentStep.index;
    if (currentIndex > 0) {
      emit(
        state.copyWith(currentStep: CreateStudentStep.values[currentIndex - 1]),
      );
    }
  }

  // ==================== Step 1: Personal Info ====================

  void updateFullName(String value) {
    emit(state.copyWith(fullName: value));
  }

  void updateClassRoom(ClassRoomModel? value) {
    if (value != null) {
      emit(state.copyWith(selectedClassRoom: value));
    } else {
      emit(state.copyWith(clearSelectedClassRoom: true));
    }
  }

  void updateAcademicYear(AcademicYearModel? value) {
    if (value != null) {
      emit(state.copyWith(selectedAcademicYear: value));
    } else {
      emit(state.copyWith(clearSelectedAcademicYear: true));
    }
  }

  void updateRoleNumber(String value) {
    emit(state.copyWith(roleNumber: value));
  }

  void updateDateOfBirth(DateTime? value) {
    if (value != null) {
      emit(state.copyWith(dateOfBirth: value));
    } else {
      emit(state.copyWith(clearDateOfBirth: true));
    }
  }

  void updateGender(String? value) {
    if (value != null) {
      emit(state.copyWith(selectedGender: value));
    } else {
      emit(state.copyWith(clearSelectedGender: true));
    }
  }

  void updateBloodGroup(String? value) {
    if (value != null) {
      emit(state.copyWith(selectedBloodGroup: value));
    } else {
      emit(state.copyWith(clearSelectedBloodGroup: true));
    }
  }

  void updateAddress(String value) {
    emit(state.copyWith(address: value));
  }

  void updateEmail(String value) {
    emit(state.copyWith(email: value));
  }

  void updatePhone(String value) {
    emit(state.copyWith(phone: value));
  }

  // ==================== Step 2: Documents ====================

  /// Add a new document.
  void addDocument(String name, File file) {
    final updatedDocuments = List<DocumentModel>.from(state.documents)
      ..add(DocumentModel(name: name, file: file));
    emit(state.copyWith(documents: updatedDocuments));
  }

  /// Remove a document at the given index.
  void removeDocument(int index) {
    if (index >= 0 && index < state.documents.length) {
      final updatedDocuments = List<DocumentModel>.from(state.documents)
        ..removeAt(index);
      emit(state.copyWith(documents: updatedDocuments));
    }
  }

  /// Update document file at the given index.
  Future<void> pickDocumentFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Check file size (max 15 MB)
        if (fileSize > 15 * 1024 * 1024) {
          emit(state.copyWith(errorMessage: 'File size exceeds 15 MB limit.'));
          return;
        }

        final updatedDocuments = List<DocumentModel>.from(state.documents);
        updatedDocuments[index] = updatedDocuments[index].copyWith(file: file);
        emit(state.copyWith(documents: updatedDocuments));
      }
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Failed to pick file. Please try again.'),
      );
    }
  }

  /// Pick file for adding new document (returns file).
  Future<File?> pickNewDocumentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Check file size (max 15 MB)
        if (fileSize > 15 * 1024 * 1024) {
          emit(state.copyWith(errorMessage: 'File size exceeds 15 MB limit.'));
          return null;
        }

        return file;
      }
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Failed to pick file. Please try again.'),
      );
    }
    return null;
  }

  // ==================== Step 3: Parent Info ====================

  void updateParentFullName(String value) {
    emit(state.copyWith(parentFullName: value));
  }

  void updateParentEmail(String value) {
    emit(state.copyWith(parentEmail: value));
  }

  void updateParentContactNo(String value) {
    emit(state.copyWith(parentContactNo: value));
  }

  void updateParentAddress(String value) {
    emit(state.copyWith(parentAddress: value));
  }

  // ==================== Step 4: Photo ====================

  /// Pick photo from gallery.
  Future<void> pickPhotoFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        // Check file size (max 5 MB)
        if (fileSize > 5 * 1024 * 1024) {
          emit(state.copyWith(errorMessage: 'Photo size exceeds 5 MB limit.'));
          return;
        }

        emit(state.copyWith(photo: file, clearExistingPhotoUrl: true));
      }
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Failed to pick photo. Please try again.'),
      );
    }
  }

  /// Pick photo from camera.
  Future<void> pickPhotoFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        // Check file size (max 5 MB)
        if (fileSize > 5 * 1024 * 1024) {
          emit(state.copyWith(errorMessage: 'Photo size exceeds 5 MB limit.'));
          return;
        }

        emit(state.copyWith(photo: file, clearExistingPhotoUrl: true));
      }
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to capture photo. Please try again.',
        ),
      );
    }
  }

  /// Remove selected photo.
  void removePhoto() {
    emit(state.copyWith(clearPhoto: true, clearExistingPhotoUrl: true));
  }

  // ==================== Form Submission ====================

  /// Submit the form - creates or updates student based on form mode.
  Future<void> submitForm() async {
    emit(state.copyWith(submissionStatus: SubmissionStatus.loading));

    try {
      if (state.isEditMode && state.editingStudentId != null) {
        await _updateStudent();
      } else {
        await _createStudent();
      }

      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: _formatApiError(e),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: state.isEditMode
              ? 'Failed to update student. Please try again.'
              : 'Failed to create student. Please try again.',
        ),
      );
    }
  }

  /// Create a new student.
  Future<void> _createStudent() async {
    if (state.schoolId == null || state.schoolId!.isEmpty) {
      throw const ApiException(message: 'School ID is required.');
    }

    // Convert documents to request format
    final documentRequests = state.documents
        .where((doc) => doc.file != null)
        .map((doc) => DocumentRequest(name: doc.name, file: doc.file))
        .toList();

    final request = CreateStudentRequest(
      email: state.email,
      phone: state.phone.isNotEmpty ? state.phone : null,
      firstName: state.fullName,
      profilePic: state.photo,
      dateOfBirth: state.dateOfBirth,
      address: state.address.isNotEmpty ? state.address : null,
      gender: state.selectedGender,
      bloodGroup: state.selectedBloodGroup,
      documents: documentRequests,
      school: state.schoolId!,
      rollNo: state.roleNumber.isNotEmpty ? state.roleNumber : null,
      classroomId: state.selectedClassRoom?.id,
      academicYearId: state.selectedAcademicYear?.id,
    );

    await _studentsRepository.createStudent(request);
  }

  /// Update an existing student.
  Future<void> _updateStudent() async {
    // Only include documents that have new files (not existing URLs)
    final newDocumentRequests = state.documents
        .where((doc) => doc.file != null)
        .map((doc) => DocumentRequest(name: doc.name, file: doc.file))
        .toList();

    final request = UpdateStudentRequest(
      email: state.email,
      phone: state.phone.isNotEmpty ? state.phone : null,
      firstName: state.fullName,
      profilePic: state.photo, // Only set if new photo was picked
      profilePicUrl: state.existingPhotoUrl,
      dateOfBirth: state.dateOfBirth,
      address: state.address,
      gender: state.selectedGender,
      bloodGroup: state.selectedBloodGroup,
      documents: newDocumentRequests,
      rollNo: state.roleNumber.isNotEmpty ? state.roleNumber : null,
      classroomId: state.selectedClassRoom?.id,
      academicYearId: state.selectedAcademicYear?.id,
    );

    await _studentsRepository.updateStudent(state.editingStudentId!, request);
  }

  /// Format API error message for user display.
  String _formatApiError(ApiException e) {
    if (e.errors != null && e.errors!.isNotEmpty) {
      final buffer = StringBuffer();
      e.errors!.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          // Handle nested errors like student_enrolment.classroom
          value.forEach((nestedKey, nestedValue) {
            if (nestedValue is List && nestedValue.isNotEmpty) {
              buffer.writeln('$nestedKey: ${nestedValue.first}');
            }
          });
        } else if (value is List && value.isNotEmpty) {
          buffer.writeln('$key: ${value.first}');
        }
      });
      final formatted = buffer.toString().trim();
      if (formatted.isNotEmpty) return formatted;
    }
    return e.message;
  }

  /// Reset the form to initial state for adding another student.
  void resetForm() {
    final studentId = _generateStudentId();
    emit(
      CreateStudentState(
        isInitialLoading: false,
        formMode: StudentFormMode.create,
        classRooms: state.classRooms,
        academicYears: state.academicYears,
        genders: state.genders,
        bloodGroups: state.bloodGroups,
        studentId: studentId,
        documents: [],
        schoolId: state.schoolId,
      ),
    );
  }

  /// Reset submission status.
  void resetSubmissionStatus() {
    emit(state.copyWith(submissionStatus: SubmissionStatus.initial));
  }

  /// Clear error message.
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
