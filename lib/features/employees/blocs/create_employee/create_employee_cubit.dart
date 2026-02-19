import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/tenant/tenant_context.dart';
import '../../../../core/utils/di.dart';
import '../../repositories/employees_repository.dart';
import '../../repositories/roles_repository.dart';
import '../../repositories/subjects_repository.dart';
import 'create_employee_state.dart';

export 'create_employee_state.dart';

/// Cubit for managing the Create Employee flow state.
class CreateEmployeeCubit extends Cubit<CreateEmployeeState> {
  CreateEmployeeCubit({
    RolesRepository? rolesRepository,
    SubjectsRepository? subjectsRepository,
    EmployeesRepository? employeesRepository,
  }) : _rolesRepository = rolesRepository ?? locator<RolesRepository>(),
       _subjectsRepository =
           subjectsRepository ?? locator<SubjectsRepository>(),
       _employeesRepository =
           employeesRepository ?? locator<EmployeesRepository>(),
       super(const CreateEmployeeState());

  final RolesRepository _rolesRepository;
  final SubjectsRepository _subjectsRepository;
  final EmployeesRepository _employeesRepository;
  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize and fetch all dropdown data.
  Future<void> initialize() async {
    emit(state.copyWith(isInitialLoading: true));

    try {
      // Fetch data in parallel - roles and subjects from API, others static
      final results = await Future.wait([
        _fetchRoles(),
        _fetchSubjects(),
        _fetchGenders(),
        _fetchBloodGroups(),
      ]);

      final roles = results[0] as List<RoleModel>;
      final subjects = results[1] as List<SubjectModel>;
      final genders = results[2] as List<String>;
      final bloodGroups = results[3] as List<String>;

      // Generate auto employee ID
      final employeeId = _generateEmployeeId();

      emit(
        state.copyWith(
          isInitialLoading: false,
          roles: roles,
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
    } catch (e, s) {
      log('CreateEmployeeCubit.initialize error: $e', stackTrace: s);
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load data. Please try again.',
        ),
      );
    }
  }

  /// Initialize for editing an existing employee.
  ///
  /// [employeeId] - The ID of the employee to edit.
  /// [employeeData] - Optional pre-loaded employee data to avoid extra API call.
  Future<void> initializeForEdit({required String employeeId}) async {
    emit(state.copyWith(isInitialLoading: true));

    try {
      // Fetch employee details from API if not provided
      Map<String, dynamic> empData = await _employeesRepository
          .getEmployeeDetailsById(employeeId);

      // Fetch dropdown data in parallel
      final results = await Future.wait([
        _fetchRoles(),
        _fetchSubjects(),
        _fetchGenders(),
        _fetchBloodGroups(),
      ]);

      final roles = results[0] as List<RoleModel>;
      final subjects = results[1] as List<SubjectModel>;
      final genders = results[2] as List<String>;
      final bloodGroups = results[3] as List<String>;

      // Parse employee data
      String fullName = '';
      String email = '';
      String mobileNo = '';
      DateTime? joiningDate;
      String? gender;
      String? bloodGroup;
      String? address;
      String? existingProfilePicUrl;
      List<RoleModel> selectedRoles = [];
      List<SubjectModel> selectedSubjects = [];
      List<EmployeeDocumentModel> documents = [];

      // Parse basic info
      final firstName = empData['first_name'] ?? '';
      final lastName = empData['last_name'] ?? '';
      fullName = '$firstName $lastName'.trim();
      email = empData['email'] ?? '';
      mobileNo = empData['phone'] ?? '';

      // Parse profile
      final profile = empData['profile'] as Map<String, dynamic>?;
      if (profile != null) {
        gender = profile['gender'];
        bloodGroup = profile['blood_group'];
        address = profile['address'];
        existingProfilePicUrl = profile['profile_pic'];

        // Parse joining date
        final joiningDateStr = profile['joining_date'];
        if (joiningDateStr != null && joiningDateStr is String) {
          joiningDate = DateTime.tryParse(joiningDateStr);
        }
      }

      // Map roles from roles_details (new format from API)
      final rolesDetails = empData['roles_details'] as List<dynamic>? ?? [];
      for (final rd in rolesDetails) {
        final roleId = rd['id']?.toString();
        if (roleId != null) {
          final role = roles.where((r) => r.id == roleId).firstOrNull;
          if (role != null) selectedRoles.add(role);
        }
      }

      // Fallback: Map role IDs if roles_details is empty
      if (selectedRoles.isEmpty) {
        final roleIds =
            (empData['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        selectedRoles = roles.where((r) => roleIds.contains(r.id)).toList();
      }

      // Map subjects from subjects_list (new format from API)
      final subjectsList = empData['subjects_list'] as List<dynamic>? ?? [];
      for (final sl in subjectsList) {
        // Try subject_id first (from response), then fall back to id
        final subjectId = sl['subject_id']?.toString() ?? sl['id']?.toString();
        if (subjectId != null) {
          final subject = subjects.where((s) => s.id == subjectId).firstOrNull;
          if (subject != null) selectedSubjects.add(subject);
        }
      }

      // Fallback: Map subject IDs if subjects_list is empty
      if (selectedSubjects.isEmpty) {
        final subjectIds =
            (empData['subjects'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        selectedSubjects = subjects
            .where((s) => subjectIds.contains(s.id))
            .toList();
      }

      // Map documents
      final docsList = empData['documents'] as List<dynamic>? ?? [];
      documents = docsList.map((d) {
        return EmployeeDocumentModel(
          id: d['id']?.toString() ?? '',
          name: d['document_name'] ?? 'Document',
          existingUrl: d['document_file'],
          isExisting: true,
        );
      }).toList();

      // Add default empty document if no documents exist
      if (documents.isEmpty) {
        documents = [
          EmployeeDocumentModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Birth Certificate',
          ),
        ];
      }

      emit(
        state.copyWith(
          isInitialLoading: false,
          isEditMode: true,
          editingEmployeeId: employeeId,
          roles: roles,
          subjects: subjects,
          genders: genders,
          bloodGroups: bloodGroups,
          // Pre-fill form fields
          fullName: fullName,
          email: email,
          mobileNo: mobileNo,
          joiningDate: joiningDate,
          selectedGender: gender,
          selectedBloodGroup: bloodGroup,
          address: address ?? '',
          selectedRoles: selectedRoles,
          selectedSubjects: selectedSubjects,
          documents: documents,
          employeeId: employeeId,
          existingProfilePicUrl: existingProfilePicUrl,
        ),
      );
    } catch (e, s) {
      log('CreateEmployeeCubit.initializeForEdit error: $e', stackTrace: s);
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load employee data. Please try again.',
        ),
      );
    }
  }

  /// Fetches roles from API.
  Future<List<RoleModel>> _fetchRoles() async {
    try {
      final roles = await _rolesRepository.getAllRoles();
      // Filter out Student and Guardian roles as they are not employee roles
      return roles
          .where(
            (role) =>
                role.name.toLowerCase() != 'student' &&
                role.name.toLowerCase() != 'guardian',
          )
          .toList();
    } catch (e) {
      log('Failed to fetch roles: $e');
      // Return empty list on error, will show error in UI
      return [];
    }
  }

  /// Fetches subjects from API.
  Future<List<SubjectModel>> _fetchSubjects() async {
    try {
      final subjects = await _subjectsRepository.getAllSubjects();
      return subjects;
    } catch (e) {
      log('Failed to fetch subjects: $e');
      // Return empty list on error
      return [];
    }
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

  /// Add a role to selected roles.
  void addRole(RoleModel role) {
    if (!state.selectedRoles.any((r) => r.id == role.id)) {
      final updatedRoles = [...state.selectedRoles, role];
      emit(state.copyWith(selectedRoles: updatedRoles));
    }
  }

  /// Remove a role from selected roles.
  void removeRole(RoleModel role) {
    final updatedRoles = state.selectedRoles
        .where((r) => r.id != role.id)
        .toList();
    emit(state.copyWith(selectedRoles: updatedRoles));
  }

  void updateFullName(String value) {
    emit(state.copyWith(fullName: value));
  }

  void updateMobileNo(String value) {
    emit(state.copyWith(mobileNo: value));
  }

  void updateJoiningDate(DateTime? value) {
    emit(state.copyWith(joiningDate: value));
  }

  void updateSubjects(List<SubjectModel> value) {
    emit(state.copyWith(selectedSubjects: value));
  }

  void addSubject(SubjectModel subject) {
    if (!state.selectedSubjects.any((s) => s.id == subject.id)) {
      final updatedSubjects = [...state.selectedSubjects, subject];
      emit(state.copyWith(selectedSubjects: updatedSubjects));
    }
  }

  void removeSubject(SubjectModel subject) {
    final updatedSubjects = state.selectedSubjects
        .where((s) => s.id != subject.id)
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
    final documentToRemove = state.documents[index];
    final updatedDocuments = List<EmployeeDocumentModel>.from(state.documents);
    updatedDocuments.removeAt(index);

    // Track deleted document IDs for edit mode (only existing documents)
    List<String>? deletedIds;
    if (state.isEditMode && documentToRemove.isExisting) {
      deletedIds = [...state.deletedDocumentIds, documentToRemove.id];
    }

    emit(
      state.copyWith(
        documents: updatedDocuments,
        deletedDocumentIds: deletedIds,
      ),
    );
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
    emit(state.copyWith(clearPhoto: true, clearExistingPhoto: true));
  }

  // ==================== Form Submission ====================

  /// Convert file to base64 data URL.
  Future<String?> _fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final extension = file.path.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        default:
          mimeType = 'application/octet-stream';
      }
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      log('Failed to convert file to base64: $e');
      return null;
    }
  }

  /// Build the request payload for create/update employee API.
  Future<Map<String, dynamic>> _buildPayload() async {
    // Split full name into first and last name
    final nameParts = state.fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Format joining date
    String? joiningDateStr;
    if (state.joiningDate != null) {
      joiningDateStr =
          '${state.joiningDate!.year}-${state.joiningDate!.month.toString().padLeft(2, '0')}-${state.joiningDate!.day.toString().padLeft(2, '0')}';
    }

    // Build profile object
    final profile = <String, dynamic>{
      'joining_date': joiningDateStr,
      'address': state.address.isNotEmpty ? state.address : null,
      'agent_id': null,
      'gender': state.selectedGender,
      'blood_group': state.selectedBloodGroup,
    };

    // Add profile picture if selected
    if (state.photo != null) {
      final profilePicBase64 = await _fileToBase64(state.photo!);
      if (profilePicBase64 != null) {
        profile['profile_pic'] = profilePicBase64;
      }
    }

    // Build documents list (only new documents with files)
    final documents = <Map<String, dynamic>>[];
    for (final doc in state.documents) {
      if (doc.file != null && !doc.isExisting) {
        final fileBase64 = await _fileToBase64(doc.file!);
        if (fileBase64 != null) {
          documents.add({
            'document_name': doc.name,
            'document_file': fileBase64,
          });
        }
      }
    }

    // Build payload
    final payload = <String, dynamic>{
      'email': state.email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': state.mobileNo,
      'school': locator<TenantContext>().selectedSchoolId,
      'is_active': true,
      'profile': profile,
      'roles': state.selectedRoles.map((r) => r.id).toList(),
      'subjects': state.selectedSubjects.map((s) => s.id).toList(),
      'documents': documents,
    };

    // Add deleted documents for update
    if (state.isEditMode && state.deletedDocumentIds.isNotEmpty) {
      payload['deleted_documents'] = state.deletedDocumentIds;
    }

    return payload;
  }

  /// Submit the employee form.
  Future<void> submitForm() async {
    emit(state.copyWith(submissionStatus: SubmissionStatus.loading));

    try {
      final payload = await _buildPayload();
      log('Submit payload: $payload');

      if (state.isEditMode && state.editingEmployeeId != null) {
        // Update existing employee
        await _employeesRepository.updateEmployee(
          state.editingEmployeeId!,
          payload,
        );
      } else {
        // Create new employee
        await _employeesRepository.createEmployee(payload);
      }

      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } catch (e, s) {
      log('CreateEmployeeCubit.submitForm error: $e', stackTrace: s);
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: state.isEditMode
              ? 'Failed to update employee. Please try again.'
              : 'Failed to create employee. Please try again.',
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
        roles: state.roles,
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
