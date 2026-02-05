import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'create_student_state.dart';

export 'create_student_state.dart';

/// Cubit for managing the Create Student flow state.
class CreateStudentCubit extends Cubit<CreateStudentState> {
  CreateStudentCubit() : super(const CreateStudentState());

  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize and fetch all dropdown data.
  Future<void> initialize() async {
    emit(state.copyWith(isInitialLoading: true));

    try {
      // Simulate parallel API calls
      final results = await Future.wait([
        _fetchClasses(),
        _fetchDivisions(),
        _fetchGenders(),
        _fetchBloodGroups(),
      ]);

      final classes = results[0];
      final divisions = results[1];
      final genders = results[2];
      final bloodGroups = results[3];

      // Generate auto student ID
      final studentId = _generateStudentId();

      emit(
        state.copyWith(
          isInitialLoading: false,
          classes: classes,
          divisions: divisions,
          genders: genders,
          bloodGroups: bloodGroups,
          studentId: studentId,
          // Add default document
          documents: [const DocumentModel(name: 'Birth Certificate')],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load data. Please try again.',
        ),
      );
    }
  }

  /// Simulates fetching classes from API.
  Future<List<String>> _fetchClasses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  }

  /// Simulates fetching divisions from API.
  Future<List<String>> _fetchDivisions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ['A', 'B', 'C', 'D', 'E'];
  }

  /// Simulates fetching genders from API.
  Future<List<String>> _fetchGenders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['Male', 'Female', 'Other'];
  }

  /// Simulates fetching blood groups from API.
  Future<List<String>> _fetchBloodGroups() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  }

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

  void updateClass(String? value) {
    emit(state.copyWith(selectedClass: value));
  }

  void updateDivision(String? value) {
    emit(state.copyWith(selectedDivision: value));
  }

  void updateAcademicYear(String value) {
    emit(state.copyWith(academicYear: value));
  }

  void updateDateOfBirth(DateTime? value) {
    emit(state.copyWith(dateOfBirth: value));
  }

  void updateGender(String? value) {
    emit(state.copyWith(selectedGender: value));
  }

  void updateBloodGroup(String? value) {
    emit(state.copyWith(selectedBloodGroup: value));
  }

  void updateAddress(String value) {
    emit(state.copyWith(address: value));
  }

  void updateEmail(String value) {
    emit(state.copyWith(email: value));
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

        emit(state.copyWith(photo: file));
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

        emit(state.copyWith(photo: file));
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
    emit(state.copyWith(clearPhoto: true));
  }

  // ==================== Form Submission ====================

  /// Submit the form and create the student.
  Future<void> submitForm() async {
    emit(state.copyWith(submissionStatus: SubmissionStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success
      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: 'Failed to create student. Please try again.',
        ),
      );
    }
  }

  /// Reset the form to initial state for adding another student.
  void resetForm() {
    final studentId = _generateStudentId();
    emit(
      CreateStudentState(
        isInitialLoading: false,
        classes: state.classes,
        genders: state.genders,
        bloodGroups: state.bloodGroups,
        studentId: studentId,
        documents: [const DocumentModel(name: 'Birth Certificate')],
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

var studentPayload = {
  "email": "dilshad@gmail.com",
  "phone": "9988998899",
  "first_name": "Dilshad",
  "profile": {
    "profile_pic":
        "data:image/jpeg;base64,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",
    "date_of_birth": "2000-12-04",
    "address": "Moorkanad Road",
    "gender": "Male",
  },
  "documents": [],
  "school": "7205c0b9-252d-4548-b0cf-2debbabad52b",
  "student_enrolment": {"roll_no": "1", "classroom": 7, "academic_year": 3},
};
