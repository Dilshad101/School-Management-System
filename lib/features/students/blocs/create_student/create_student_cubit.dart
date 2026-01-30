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
          documents: [const DocumentModel(name: 'birth certificate')],
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
        divisions: state.divisions,
        genders: state.genders,
        bloodGroups: state.bloodGroups,
        studentId: studentId,
        documents: [const DocumentModel(name: 'birth certificate')],
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
