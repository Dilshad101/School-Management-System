import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

import '../../blocs/create_employee/create_employee_cubit.dart';
import 'widgets/add_employee_document_dialog.dart';
import 'widgets/employee_created_dialog.dart';
import 'widgets/employee_documents_step.dart';
import 'widgets/employee_personal_info_step.dart';
import 'widgets/employee_photo_step.dart';
import 'widgets/employee_step_indicator.dart';

class CreateEmployeeView extends StatelessWidget {
  const CreateEmployeeView({super.key, required this.initialCategory});

  final StaffCategoryModel? initialCategory;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateEmployeeCubit()..initialize(initialCategory),
      child: const _CreateEmployeeViewContent(),
    );
  }
}

class _CreateEmployeeViewContent extends StatefulWidget {
  const _CreateEmployeeViewContent();

  @override
  State<_CreateEmployeeViewContent> createState() =>
      _CreateEmployeeViewContentState();
}

class _CreateEmployeeViewContentState
    extends State<_CreateEmployeeViewContent> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateEmployeeCubit, CreateEmployeeState>(
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
          context.read<CreateEmployeeCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(_getAppBarTitle(state)),
            centerTitle: true,
          ),
          body: state.isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(child: _buildStepContent(context, state)),
                    _buildBottomSection(context, state),
                  ],
                ),
        );
      },
    );
  }

  String _getAppBarTitle(CreateEmployeeState state) {
    if (!state.hasCategorySelected) {
      return 'Add Employee';
    }
    return state.categoryLabel == 'Teachers'
        ? 'Add Teacher'
        : 'Add ${state.categoryLabel}';
  }

  Widget _buildStepContent(BuildContext context, CreateEmployeeState state) {
    final cubit = context.read<CreateEmployeeCubit>();

    switch (state.currentStep) {
      case CreateEmployeeStep.personalInfo:
        return EmployeePersonalInfoStep(
          formKey: _step1FormKey,
          fullName: state.fullName,
          mobileNo: state.mobileNo,
          joiningDate: state.joiningDate,
          selectedSubjects: state.selectedSubjects,
          selectedGender: state.selectedGender,
          selectedBloodGroup: state.selectedBloodGroup,
          address: state.address,
          email: state.email,
          employeeId: state.employeeId,
          subjects: state.subjects,
          genders: state.genders,
          bloodGroups: state.bloodGroups,
          categoryLabel: state.categoryLabel,
          onFullNameChanged: cubit.updateFullName,
          onMobileNoChanged: cubit.updateMobileNo,
          onJoiningDateChanged: cubit.updateJoiningDate,
          onSubjectAdded: cubit.addSubject,
          onSubjectRemoved: cubit.removeSubject,
          onGenderChanged: cubit.updateGender,
          onBloodGroupChanged: cubit.updateBloodGroup,
          onAddressChanged: cubit.updateAddress,
          onEmailChanged: cubit.updateEmail,
        );

      case CreateEmployeeStep.documents:
        return EmployeeDocumentsStep(
          formKey: _step2FormKey,
          documents: state.documents,
          employeeName: state.displayName,
          onPickFile: cubit.pickDocumentFile,
          onAddDocument: () => _showAddDocumentDialog(context, state),
          onRemoveDocument: cubit.removeDocument,
          onEditDocument: cubit.updateDocumentName,
        );

      case CreateEmployeeStep.photo:
        return EmployeePhotoStep(
          formKey: _step3FormKey,
          employeeName: state.displayName,
          photo: state.photo,
          onPickFromGallery: cubit.pickPhotoFromGallery,
          onPickFromCamera: cubit.pickPhotoFromCamera,
          onRemovePhoto: cubit.removePhoto,
        );
    }
  }

  Widget _buildBottomSection(BuildContext context, CreateEmployeeState state) {
    final cubit = context.read<CreateEmployeeCubit>();

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
            EmployeeStepIndicator(
              currentStep: state.currentStepIndex,
              totalSteps: state.totalSteps,
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                // Previous button (only show if not first step)
                if (!state.isFirstStep) ...[
                  Expanded(
                    child: OutlineButton(
                      label: 'Previous',
                      onPressed: cubit.goToPreviousStep,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Next/Submit button
                Expanded(
                  flex: state.isFirstStep ? 1 : 1,
                  child: GradientButton(
                    label: state.isLastStep ? 'Add' : 'Next',
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

  void _onNextOrSubmit(BuildContext context, CreateEmployeeState state) {
    final cubit = context.read<CreateEmployeeCubit>();
    final formKey = _getFormKeyForStep(state.currentStep);

    if (formKey.currentState?.validate() ?? false) {
      // Additional validation for documents step
      if (state.currentStep == CreateEmployeeStep.documents) {
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

  GlobalKey<FormState> _getFormKeyForStep(CreateEmployeeStep step) {
    switch (step) {
      case CreateEmployeeStep.personalInfo:
        return _step1FormKey;
      case CreateEmployeeStep.documents:
        return _step2FormKey;
      case CreateEmployeeStep.photo:
        return _step3FormKey;
    }
  }

  void _showAddDocumentDialog(
    BuildContext context,
    CreateEmployeeState state,
  ) async {
    final cubit = context.read<CreateEmployeeCubit>();

    await AddEmployeeDocumentDialog.show(
      context: context,
      employeeName: state.displayName,
      onPickFile: cubit.pickNewDocumentFile,
      onAdd: (name, file) {
        cubit.addDocument(name, file);
      },
    );
  }

  void _showSuccessDialog(BuildContext context, CreateEmployeeState state) {
    final cubit = context.read<CreateEmployeeCubit>();

    EmployeeCreatedDialog.show(
      context: context,
      employeeName: state.fullName.isNotEmpty ? state.fullName : 'Employee',
      employeeId: state.employeeId,
      categoryLabel: state.categoryLabel,
      onViewProfile: () {
        Navigator.pop(context); // Close dialog
        cubit.resetSubmissionStatus();
        context.pop(); // Navigate back to employees list
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
