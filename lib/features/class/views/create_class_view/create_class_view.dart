import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/core/utils/di.dart';
import 'package:school_management_system/features/class/blocs/create_class/create_class_cubit.dart';
import 'package:school_management_system/features/class/repositories/classroom_repository.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

import 'widgets/class_created_dialog.dart';
import 'widgets/class_details_step.dart';

class CreateClassView extends StatelessWidget {
  const CreateClassView({super.key, this.classroomId});

  /// The classroom ID for edit mode. If null, creates a new class.
  final String? classroomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CreateClassCubit(
          repository: locator<ClassroomRepository>(),
        );
        if (classroomId != null) {
          cubit.initializeForEdit(classroomId!);
        } else {
          cubit.initialize();
        }
        return cubit;
      },
      child: _CreateClassViewContent(isEditMode: classroomId != null),
    );
  }
}

class _CreateClassViewContent extends StatefulWidget {
  const _CreateClassViewContent({required this.isEditMode});

  final bool isEditMode;

  @override
  State<_CreateClassViewContent> createState() =>
      _CreateClassViewContentState();
}

class _CreateClassViewContentState extends State<_CreateClassViewContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateClassCubit, CreateClassState>(
      listenWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus,
      listener: (context, state) {
        if (state.isSuccess) {
          _showSuccessDialog(context, state);
        } else if (state.isFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(state.isEditMode ? 'Edit Class' : 'Add Class'),
            centerTitle: true,
          ),
          body: state.isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Main content
                    Expanded(child: _buildFormContent(context, state)),

                    // Bottom section with submit button
                    _buildBottomSection(context, state),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFormContent(BuildContext context, CreateClassState state) {
    final cubit = context.read<CreateClassCubit>();

    return ClassDetailsStep(
      formKey: _formKey,
      className: state.className,
      roomNo: state.roomNo,
      selectedAcademicYear: state.selectedAcademicYear,
      selectedClassTeacher: state.selectedClassTeacher,
      onClassNameChanged: cubit.updateClassName,
      onRoomNoChanged: cubit.updateRoomNo,
      onAcademicYearChanged: cubit.updateAcademicYear,
      onClassTeacherChanged: cubit.updateClassTeacher,
      searchAcademicYears: cubit.searchAcademicYears,
      searchSchoolUsers: cubit.searchSchoolUsers,
    );
  }

  Widget _buildBottomSection(BuildContext context, CreateClassState state) {
    final cubit = context.read<CreateClassCubit>();

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
        child: GradientButton(
          label: state.isEditMode ? 'Update' : 'Submit',
          isLoading: state.isSubmitting,
          onPressed: state.isSubmitting
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    cubit.submitForm();
                  }
                },
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, CreateClassState state) {
    final cubit = context.read<CreateClassCubit>();

    if (state.isEditMode) {
      // For edit mode, just go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      cubit.resetSubmissionStatus();
      context.pop();
      return;
    }

    // For create mode, show success dialog
    ClassCreatedDialog.show(
      context: context,
      className: state.className,
      classTeacher: state.selectedClassTeacher?.fullName ?? '',
      onViewClass: () {
        Navigator.pop(context); // Close dialog
        cubit.resetSubmissionStatus();
        context.go(Routes.classes); // Navigate to classes
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
}
