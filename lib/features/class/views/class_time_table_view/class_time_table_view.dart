import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/features/class/blocs/timetable/timetable_cubit.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

import 'widgets/day_form_view.dart';
import 'widgets/preview_view.dart';
import 'widgets/timetable_step_indicator.dart';

class ClassTimeTableView extends StatelessWidget {
  const ClassTimeTableView({super.key, this.isEditMode = false});

  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimetableCubit()..initialize(isEditMode: isEditMode),
      child: const _ClassTimeTableContent(),
    );
  }
}

class _ClassTimeTableContent extends StatelessWidget {
  const _ClassTimeTableContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Timetable'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<TimetableCubit, TimetableState>(
        listener: (context, state) {
          // Handle success
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Timetable saved successfully!'),
                backgroundColor: AppColors.green,
              ),
            );
            Navigator.of(context).pop();
          }

          // Handle error
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<TimetableCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                // Main content
                Expanded(
                  child: state.isOnPreviewStep
                      ? const PreviewView()
                      : const DayFormView(),
                ),

                // Bottom section with step indicator and buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Step indicator
                      TimetableStepIndicator(
                        currentStep: state.currentStepIndex,
                        totalSteps: 6,
                      ),
                      const SizedBox(height: 16),

                      // Navigation buttons
                      _buildNavigationButton(context, state),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, TimetableState state) {
    final cubit = context.read<TimetableCubit>();

    if (state.isOnPreviewStep) {
      return GradientButton(
        label: 'Confirm',
        isLoading: state.isSubmitting,
        onPressed: state.isSubmitting ? null : () => cubit.submitTimetable(),
      );
    }

    return GradientButton(label: 'Next', onPressed: () => cubit.goToNextStep());
  }
}
