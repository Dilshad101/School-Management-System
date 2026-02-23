import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/features/students/blocs/create_student/create_student_cubit.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

import 'widgets/add_document_dialog.dart';
import 'widgets/documents_step.dart';
import 'widgets/parent_info_step.dart';
import 'widgets/personal_info_step.dart';
import 'widgets/photo_step.dart';
import 'widgets/student_created_dialog.dart';
import 'widgets/student_step_indicator.dart';

class CreateStudentView extends StatelessWidget {
  const CreateStudentView({super.key, this.studentId});

  /// If provided, the view will load the student and enter edit mode.
  final String? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CreateStudentCubit();
        if (studentId != null) {
          cubit.initializeForEdit(studentId!);
        } else {
          cubit.initialize();
        }
        return cubit;
      },
      child: const _CreateStudentViewContent(),
    );
  }
}

class _CreateStudentViewContent extends StatefulWidget {
  const _CreateStudentViewContent();

  @override
  State<_CreateStudentViewContent> createState() =>
      _CreateStudentViewContentState();
}

class _CreateStudentViewContentState extends State<_CreateStudentViewContent> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateStudentCubit, CreateStudentState>(
      listenWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.isSuccess) {
          _showSuccessDialog(context, state);
        } else if (state.isFailure && state.errorMessage != null) {
          _showErrorSnackBar(context, state.errorMessage!);
        } else if (state.errorMessage != null) {
          _showErrorSnackBar(context, state.errorMessage!);
          context.read<CreateStudentCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(state.isEditMode ? 'Edit Student' : 'Add Student'),
            centerTitle: true,
          ),
          body: state.isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Main content
                    Expanded(child: _buildStepContent(context, state)),

                    // Bottom section with step indicator and buttons
                    _buildBottomSection(context, state),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, CreateStudentState state) {
    final cubit = context.read<CreateStudentCubit>();

    switch (state.currentStep) {
      case CreateStudentStep.personalInfo:
        return PersonalInfoStep(
          formKey: _step1FormKey,
          fullName: state.fullName,
          selectedClassRoom: state.selectedClassRoom,
          selectedAcademicYear: state.selectedAcademicYear,
          roleNumber: state.roleNumber,
          dateOfBirth: state.dateOfBirth,
          selectedGender: state.selectedGender,
          selectedBloodGroup: state.selectedBloodGroup,
          address: state.address,
          email: state.email,
          phone: state.phone,
          studentId: state.studentId,
          classRooms: state.classRooms,
          genders: state.genders,
          academicYears: state.academicYears,
          bloodGroups: state.bloodGroups,
          onFullNameChanged: cubit.updateFullName,
          onClassRoomChanged: cubit.updateClassRoom,
          onAcademicYearChanged: cubit.updateAcademicYear,
          onRoleNumberChanged: cubit.updateRoleNumber,
          onDateOfBirthChanged: cubit.updateDateOfBirth,
          onGenderChanged: cubit.updateGender,
          onBloodGroupChanged: cubit.updateBloodGroup,
          onAddressChanged: cubit.updateAddress,
          onEmailChanged: cubit.updateEmail,
          onPhoneChanged: cubit.updatePhone,
        );

      case CreateStudentStep.documents:
        return DocumentsStep(
          formKey: _step2FormKey,
          documents: state.documents,
          studentName: state.displayName,
          onPickFile: cubit.pickDocumentFile,
          onAddDocument: () => _showAddDocumentDialog(context, state),
          onRemoveDocument: cubit.removeDocument,
        );

      case CreateStudentStep.parentInfo:
        return ParentInfoStep(
          formKey: _step3FormKey,
          fullName: state.parentFullName,
          email: state.parentEmail,
          contactNo: state.parentContactNo,
          address: state.parentAddress,
          onFullNameChanged: cubit.updateParentFullName,
          onEmailChanged: cubit.updateParentEmail,
          onContactNoChanged: cubit.updateParentContactNo,
          onAddressChanged: cubit.updateParentAddress,
        );

      case CreateStudentStep.photo:
        return PhotoStep(
          formKey: _step4FormKey,
          studentName: state.displayName,
          photo: state.photo,
          existingPhotoUrl: state.existingPhotoUrl,
          onPickFromGallery: cubit.pickPhotoFromGallery,
          onPickFromCamera: cubit.pickPhotoFromCamera,
          onRemovePhoto: cubit.removePhoto,
        );
    }
  }

  Widget _buildBottomSection(BuildContext context, CreateStudentState state) {
    final cubit = context.read<CreateStudentCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step indicator
            StudentStepIndicator(
              currentStep: state.currentStepIndex,
              totalSteps: state.totalSteps,
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                // Previous button (always show, but disabled on first step)
                Expanded(
                  child: OutlineButton(
                    label: 'Previous',
                    onPressed: state.isFirstStep
                        ? null
                        : cubit.goToPreviousStep,
                  ),
                ),
                const SizedBox(width: 12),
                // Next/Submit button
                Expanded(
                  child: GradientButton(
                    label: state.isLastStep ? 'Submit' : 'Next',
                    isLoading: state.isSubmitting,
                    onPressed: state.isSubmitting
                        ? null
                        : () => _onNextOrSubmit(context, state),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onNextOrSubmit(BuildContext context, CreateStudentState state) {
    final cubit = context.read<CreateStudentCubit>();
    final formKey = _getFormKeyForStep(state.currentStep);

    if (formKey.currentState?.validate() ?? false) {
      // Additional validation for documents step
      if (state.currentStep == CreateStudentStep.documents) {
        final hasAllFiles = state.documents.every((doc) => doc.hasFile);
        if (!hasAllFiles) {
          _showErrorSnackBar(context, 'Please upload all required documents');
          return;
        }
      }

      if (state.isLastStep) {
        cubit.submitForm();
      } else {
        cubit.goToNextStep();
      }
    }
  }

  GlobalKey<FormState> _getFormKeyForStep(CreateStudentStep step) {
    switch (step) {
      case CreateStudentStep.personalInfo:
        return _step1FormKey;
      case CreateStudentStep.documents:
        return _step2FormKey;
      case CreateStudentStep.parentInfo:
        return _step3FormKey;
      case CreateStudentStep.photo:
        return _step4FormKey;
    }
  }

  void _showAddDocumentDialog(
    BuildContext context,
    CreateStudentState state,
  ) async {
    final cubit = context.read<CreateStudentCubit>();

    await AddDocumentDialog.show(
      context: context,
      studentName: state.displayName,
      onPickFile: cubit.pickNewDocumentFile,
      onAdd: (name, file) {
        cubit.addDocument(name, file);
      },
    );
  }

  void _showSuccessDialog(BuildContext context, CreateStudentState state) {
    final cubit = context.read<CreateStudentCubit>();

    if (state.isEditMode) {
      // For edit mode, show a simple success snackbar and go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      cubit.resetSubmissionStatus();
      context.pop();
      return;
    }

    StudentCreatedDialog.show(
      context: context,
      studentName: state.fullName.isNotEmpty ? state.fullName : 'Student',
      studentId: state.studentId,
      onViewStudent: () {
        Navigator.pop(context); // Close dialog
        cubit.resetSubmissionStatus();
        context.pop(); // Navigate back to students list
      },
      onAddAnother: () {
        Navigator.pop(context); // Close dialog
        cubit.resetForm();
      },
      onClose: () {
        Navigator.pop(context); // Close dialog
        cubit.resetSubmissionStatus();
        context.pop(); // Go back
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
