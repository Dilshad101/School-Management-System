import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/features/class/blocs/create_class/create_class_cubit.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

import 'widgets/class_created_dialog.dart';
import 'widgets/class_details_step.dart';
import 'widgets/step_indicator.dart';
import 'widgets/subjects_step.dart';

class CreateClassView extends StatelessWidget {
  const CreateClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateClassCubit()..initialize(),
      child: const _CreateClassViewContent(),
    );
  }
}

class _CreateClassViewContent extends StatefulWidget {
  const _CreateClassViewContent();

  @override
  State<_CreateClassViewContent> createState() =>
      _CreateClassViewContentState();
}

class _CreateClassViewContentState extends State<_CreateClassViewContent> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

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
          appBar: AppBar(title: const Text('Add class'), centerTitle: true),
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

  Widget _buildStepContent(BuildContext context, CreateClassState state) {
    final cubit = context.read<CreateClassCubit>();

    if (state.isOnClassDetailsStep) {
      return ClassDetailsStep(
        formKey: _step1FormKey,
        className: state.className,
        roomNo: state.roomNo,
        academicYear: state.academicYear,
        classTeacher: state.classTeacher,
        selectedDivision: state.selectedDivision,
        divisions: state.divisions,
        onClassNameChanged: cubit.updateClassName,
        onRoomNoChanged: cubit.updateRoomNo,
        onAcademicYearChanged: cubit.updateAcademicYear,
        onClassTeacherChanged: cubit.updateClassTeacher,
        onDivisionChanged: cubit.updateDivision,
      );
    } else {
      return SubjectsStep(
        formKey: _step2FormKey,
        subjects: state.subjects,
        teachers: state.teachers,
        onAddSubject: cubit.addSubject,
        onRemoveSubject: cubit.removeSubject,
        onSubjectChanged: cubit.updateSubjectName,
        onTeacherChanged: cubit.updateSubjectTeacher,
      );
    }
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step indicator
            StepIndicator(
              currentStep: state.isOnClassDetailsStep ? 0 : 1,
              totalSteps: 2,
            ),
            const SizedBox(height: 16),

            // Buttons
            if (state.isOnClassDetailsStep)
              GradientButton(
                label: 'Next',
                onPressed: () => _onNextPressed(context),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: 'Previous',
                      onPressed: cubit.goToPreviousStep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'Submit',
                      isLoading: state.isSubmitting,
                      onPressed: state.isSubmitting ? null : cubit.submitForm,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _onNextPressed(BuildContext context) {
    if (_step1FormKey.currentState?.validate() ?? false) {
      context.read<CreateClassCubit>().goToNextStep();
    }
  }

  void _showSuccessDialog(BuildContext context, CreateClassState state) {
    final cubit = context.read<CreateClassCubit>();

    ClassCreatedDialog.show(
      context: context,
      className: state.formattedClassName.isNotEmpty
          ? state.formattedClassName
          : '8 - B',
      classTeacher: state.classTeacher.isNotEmpty
          ? state.classTeacher
          : 'Thomas',
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
