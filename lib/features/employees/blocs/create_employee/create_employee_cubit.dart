import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'create_employee_state.dart';

export 'create_employee_state.dart';

/// Cubit for managing the Create Employee flow state.
class CreateEmployeeCubit extends Cubit<CreateEmployeeState> {
  CreateEmployeeCubit() : super(const CreateEmployeeState());

  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize and fetch all dropdown data.
  Future<void> initialize(StaffCategoryModel? initialCategory) async {
    emit(state.copyWith(isInitialLoading: true));

    try {
      // Simulate parallel API calls
      final results = await Future.wait([
        _fetchSubjects(),
        _fetchGenders(),
        _fetchBloodGroups(),
      ]);

      final subjects = results[0];
      final genders = results[1];
      final bloodGroups = results[2];

      // Generate auto employee ID
      final employeeId = _generateEmployeeId();

      emit(
        state.copyWith(
          isInitialLoading: false,
          selectedStaffCategory: initialCategory,
          subjects: subjects,
          genders: genders,
          bloodGroups: bloodGroups,
          employeeId: employeeId,
          // Add default document
          documents: [
            EmployeeDocumentModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: 'Birth Certificate',
            ),
          ],
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

  /// Simulates fetching subjects from API.
  Future<List<String>> _fetchSubjects() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      'English',
      'Mathematics',
      'Science',
      'Social Studies',
      'Hindi',
      'Physics',
      'Chemistry',
      'Biology',
      'Computer Science',
      'Physical Education',
    ];
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

  /// Generates a unique employee ID.
  String _generateEmployeeId() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0');
  }

  // ==================== Step Navigation ====================

  /// Move to the next step.
  void goToNextStep() {
    final currentIndex = state.currentStep.index;
    if (currentIndex < CreateEmployeeStep.values.length - 1) {
      emit(
        state.copyWith(
          currentStep: CreateEmployeeStep.values[currentIndex + 1],
        ),
      );
    }
  }

  /// Move to the previous step.
  void goToPreviousStep() {
    final currentIndex = state.currentStep.index;
    if (currentIndex > 0) {
      emit(
        state.copyWith(
          currentStep: CreateEmployeeStep.values[currentIndex - 1],
        ),
      );
    }
  }

  // ==================== Step 1: Personal Info ====================

  void updateFullName(String value) {
    emit(state.copyWith(fullName: value));
  }

  void updateMobileNo(String value) {
    emit(state.copyWith(mobileNo: value));
  }

  void updateJoiningDate(DateTime? value) {
    emit(state.copyWith(joiningDate: value));
  }

  void updateSubjects(List<String> value) {
    emit(state.copyWith(selectedSubjects: value));
  }

  void addSubject(String subject) {
    if (!state.selectedSubjects.contains(subject)) {
      final updatedSubjects = [...state.selectedSubjects, subject];
      emit(state.copyWith(selectedSubjects: updatedSubjects));
    }
  }

  void removeSubject(String subject) {
    final updatedSubjects = state.selectedSubjects
        .where((s) => s != subject)
        .toList();
    emit(state.copyWith(selectedSubjects: updatedSubjects));
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

  /// Pick a file for an existing document.
  Future<void> pickDocumentFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final updatedDocuments = List<EmployeeDocumentModel>.from(
          state.documents,
        );
        updatedDocuments[index] = updatedDocuments[index].copyWith(file: file);
        emit(state.copyWith(documents: updatedDocuments));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick file'));
    }
  }

  /// Pick a file for a new document (returns File for dialog use).
  Future<File?> pickNewDocumentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick file'));
    }
    return null;
  }

  /// Add a new document with name and file.
  void addDocument(String name, File file) {
    final newDocument = EmployeeDocumentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      file: file,
    );
    final updatedDocuments = [...state.documents, newDocument];
    emit(state.copyWith(documents: updatedDocuments));
  }

  /// Remove a document by index.
  void removeDocument(int index) {
    final updatedDocuments = List<EmployeeDocumentModel>.from(state.documents);
    updatedDocuments.removeAt(index);
    emit(state.copyWith(documents: updatedDocuments));
  }

  /// Update document name (edit functionality).
  void updateDocumentName(int index, String newName) {
    if (newName.trim().isEmpty) return;
    final updatedDocuments = List<EmployeeDocumentModel>.from(state.documents);
    updatedDocuments[index] = updatedDocuments[index].copyWith(
      name: newName.trim(),
    );
    emit(state.copyWith(documents: updatedDocuments));
  }

  // ==================== Step 3: Photo ====================

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
        emit(state.copyWith(photo: File(image.path)));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick image'));
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
        emit(state.copyWith(photo: File(image.path)));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to capture image'));
    }
  }

  /// Remove the selected photo.
  void removePhoto() {
    emit(state.copyWith(clearPhoto: true));
  }

  // ==================== Form Submission ====================

  /// Submit the employee form.
  Future<void> submitForm() async {
    emit(state.copyWith(submissionStatus: SubmissionStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful response
      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: 'Failed to create employee. Please try again.',
        ),
      );
    }
  }

  /// Reset the submission status (used after showing success dialog).
  void resetSubmissionStatus() {
    emit(state.copyWith(submissionStatus: SubmissionStatus.initial));
  }

  /// Clear any error message.
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Reset the entire form for adding another employee.
  void resetForm() {
    final employeeId = _generateEmployeeId();
    emit(
      CreateEmployeeState(
        isInitialLoading: false,
        selectedStaffCategory: state.selectedStaffCategory,
        subjects: state.subjects,
        genders: state.genders,
        bloodGroups: state.bloodGroups,
        employeeId: employeeId,
        documents: [
          EmployeeDocumentModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Birth Certificate',
          ),
        ],
      ),
    );
  }
}
