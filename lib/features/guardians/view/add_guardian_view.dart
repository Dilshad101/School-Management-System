import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/utils/validations.dart';

import '../../../core/utils/di.dart';
import '../../../shared/styles/app_styles.dart';
import '../../../shared/widgets/buttons/gradient_button.dart';
import '../../../shared/widgets/input_fields/simple_form_field.dart';
import '../../../shared/widgets/input_fields/suggestion_form_field.dart';
import '../blocs/add_guardian/add_guardian_cubit.dart';
import '../blocs/add_guardian/add_guardian_state.dart';
import '../models/guardian_model.dart';
import '../repositories/guardians_repository.dart';
import 'widgets/linked_student_card.dart';
import 'widgets/guardian_success_dialog.dart';

class AddGuardianView extends StatelessWidget {
  const AddGuardianView({super.key, required this.schoolId, this.guardianId});

  final String schoolId;
  final String? guardianId;

  bool get isEditMode => guardianId != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddGuardianCubit(
        guardiansRepository: locator<GuardiansRepository>(),
        schoolId: schoolId,
        guardianId: guardianId,
      ),
      child: _AddGuardianContent(isEditMode: isEditMode),
    );
  }
}

class _AddGuardianContent extends StatefulWidget {
  const _AddGuardianContent({this.isEditMode = false});

  final bool isEditMode;

  @override
  State<_AddGuardianContent> createState() => _AddGuardianContentState();
}

class _AddGuardianContentState extends State<_AddGuardianContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _studentSearchController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _studentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Guardian' : 'Add Guardian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AddGuardianCubit, AddGuardianState>(
        listener: (context, state) {
          // Show error snackbar
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            context.read<AddGuardianCubit>().clearError();
          }

          // Update form fields when guardian is looked up (create mode)
          if (state.isLookupSuccess && state.existingGuardian != null) {
            _firstNameController.text = state.fullName;
            _emailController.text = state.email;
            _phoneController.text = state.phone;
            _addressController.text = state.address;
          }

          // Update form fields when guardian details are loaded (edit mode)
          if (widget.isEditMode &&
              !state.isLoading &&
              state.status == AddGuardianStatus.initial &&
              _emailController.text.isEmpty &&
              state.email.isNotEmpty) {
            _emailController.text = state.email;
            _firstNameController.text = state.fullName;
            _phoneController.text = state.phone;
            _addressController.text = state.address;
          }

          // Show success dialog
          if (state.isSuccess && state.createdGuardian != null) {
            if (widget.isEditMode) {
              // For edit mode, just pop with success result
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.successMessage ?? 'Guardian updated successfully',
                    ),
                    backgroundColor: AppColors.green,
                  ),
                );
              context.pop(true);
            } else {
              _showSuccessDialog(context, state.createdGuardian!);
            }
          }

          // Handle delete success
          if (state.isDeleteSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.successMessage ?? 'Guardian deleted successfully',
                  ),
                  backgroundColor: AppColors.green,
                ),
              );
            context.pop(true);
          }
        },
        builder: (context, state) {
          // Show loading indicator when loading guardian details in edit mode
          if (state.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email lookup section (hide in edit mode)
                  if (!widget.isEditMode)
                    _buildEmailLookupSection(context, state),

                  // Success/Info message for lookup
                  if (!widget.isEditMode &&
                      state.successMessage != null &&
                      (state.isLookupSuccess || state.isLookupNotFound))
                    _buildLookupMessage(state),

                  if (!widget.isEditMode) const SizedBox(height: 24),

                  // Guardian Information Section
                  _buildInformationSection(context, state),

                  const SizedBox(height: 24),

                  // Link Students Section
                  _buildLinkStudentsSection(context, state),

                  const SizedBox(height: 32),

                  // Submit Button
                  GradientButton(
                    label: widget.isEditMode ? 'Update' : 'Add',
                    isLoading: state.isSubmitting,
                    onPressed: state.canSubmit
                        ? () => context.read<AddGuardianCubit>().submitForm()
                        : null,
                  ),

                  // Delete Button (only in edit mode)
                  if (widget.isEditMode) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => _showDeleteConfirmation(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Delete Guardian',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Guardian'),
        content: const Text(
          'Are you sure you want to delete this guardian? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AddGuardianCubit>().deleteGuardian();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailLookupSection(
    BuildContext context,
    AddGuardianState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyMedium,
                enabled: !state.isLookingUp,
                decoration: InputDecoration(
                  hintText: 'Enter email',
                  hintStyle: AppTextStyles.hint,
                  prefixIcon: const Icon(
                    Icons.mail_outline,
                    size: 20,
                    color: AppColors.iconDefault,
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  context.read<AddGuardianCubit>().updateEmail(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            _buildConfirmButton(context, state),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context, AddGuardianState state) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: state.isLookingUp
            ? null
            : () {
                context.read<AddGuardianCubit>().lookupGuardianByEmail(
                  _emailController.text.trim(),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: state.isLookingUp
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text('Confirm', style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildLookupMessage(AddGuardianState state) {
    final isSuccess = state.isLookupSuccess;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info_outline,
            size: 18,
            color: isSuccess ? AppColors.green : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.successMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSuccess ? AppColors.green : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(
    BuildContext context,
    AddGuardianState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Information',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!state.isEditable && state.isExistingGuardian)
                IconButton(
                  onPressed: () {
                    context.read<AddGuardianCubit>().enableEditing();
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // First Name
          SimpleFormField(
            controller: _firstNameController,
            label: 'First Name',
            hint: 'Enter first name',
            enabled: state.isEditable,
            isRequired: true,
            onChanged: (value) {
              context.read<AddGuardianCubit>().updateFullName(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Last Name
          SimpleFormField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter email',
            enabled: state.isEditable,
            isRequired: true,
            validator: (value) => Validations.validateEmail(value),
            onChanged: (value) {
              context.read<AddGuardianCubit>().updateEmail(value);
            },
          ),
          const SizedBox(height: 16),

          // Contact Number
          SimpleFormField(
            controller: _phoneController,
            label: 'Contact No',
            hint: 'Enter contact number',
            keyboardType: TextInputType.phone,
            enabled: state.isEditable,
            isRequired: true,

            onChanged: (value) {
              context.read<AddGuardianCubit>().updatePhone(value);
            },
            validator: (value) => Validations.validatePhoneNumber(value),
          ),
          const SizedBox(height: 16),

          // Address
          SimpleFormField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter address',
            enabled: state.isEditable,
            maxLines: 2,
            onChanged: (value) {
              context.read<AddGuardianCubit>().updateAddress(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinkStudentsSection(
    BuildContext context,
    AddGuardianState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Linked Students',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Student search field with suggestions
          SuggestionFormField<LinkedStudentModel>(
            controller: _studentSearchController,
            label: 'Search Student',
            hint: 'Search by name or ID',
            isRequired: state.linkedStudents.isEmpty,
            prefixIcon: const Icon(Icons.search),
            minCharsForSuggestions: 2,
            suggestionsCallback: (pattern) async {
              return await context.read<AddGuardianCubit>().searchStudents(
                pattern,
              );
            },
            itemBuilder: (context, student) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.border.withAlpha(50),
                  backgroundImage: student.profilePic != null
                      ? NetworkImage(student.profilePic!)
                      : null,
                  child: student.profilePic == null
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                title: Text(
                  student.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${student.classInfo} | ${student.displayId}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
            onSelected: (student) {
              context.read<AddGuardianCubit>().addLinkedStudent(student);
              _studentSearchController.clear();
            },
          ),

          const SizedBox(height: 16),

          // Linked students list
          if (state.linkedStudents.isNotEmpty) ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.linkedStudents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = state.linkedStudents[index];
                return LinkedStudentCard(
                  student: student,
                  onRemove: () {
                    context.read<AddGuardianCubit>().removeLinkedStudent(
                      student.id,
                    );
                  },
                  onRelationChanged: (relation) {
                    context.read<AddGuardianCubit>().updateStudentRelation(
                      student.id,
                      relation,
                    );
                  },
                  onView: () {
                    // TODO: Navigate to student details
                  },
                );
              },
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppColors.textSecondary.withAlpha(100),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No students linked yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search and add students to link with this guardian',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, GuardianModel guardian) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GuardianSuccessDialog(
        guardianName: guardian.displayName,
        linkedStudentName:
            context
                .read<AddGuardianCubit>()
                .state
                .linkedStudents
                .firstOrNull
                ?.name ??
            '',
        onViewProfile: () {
          Navigator.of(dialogContext).pop();
          // Return true to trigger refresh in the guardians list
          context.pop(true);
          // TODO: Navigate to guardian profile
        },
        onAddAnother: () {
          Navigator.of(dialogContext).pop();
          context.read<AddGuardianCubit>().resetForm();
          _clearAllFields();
        },
        onClose: () {
          Navigator.of(dialogContext).pop();
          // Return true to trigger refresh in the guardians list
          context.pop(true);
        },
      ),
    );
  }

  void _clearAllFields() {
    _emailController.clear();
    _firstNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _studentSearchController.clear();
  }
}
