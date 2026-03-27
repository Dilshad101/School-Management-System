import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/utils/di.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../blocs/employee_details/employee_details_cubit.dart';
import '../../blocs/employee_details/employee_details_state.dart';
import '../../repositories/employees_repository.dart';
import 'widgets/employee_documents_section.dart';
import 'widgets/employee_header.dart';
import 'widgets/employee_info_section.dart';

class EmployeeDetailsView extends StatelessWidget {
  const EmployeeDetailsView({super.key, required this.employeeId});

  final String? employeeId;

  @override
  Widget build(BuildContext context) {
    if (employeeId == null || employeeId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Employee')),
        body: const Center(child: Text('Invalid employee ID')),
      );
    }

    return BlocProvider(
      create: (context) => EmployeeDetailsCubit(
        employeesRepository: locator<EmployeesRepository>(),
      )..fetchEmployeeDetails(employeeId!),
      child: _EmployeeDetailsContent(employeeId: employeeId!),
    );
  }
}

class _EmployeeDetailsContent extends StatelessWidget {
  const _EmployeeDetailsContent({required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _onEdit(context);
              } else if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<EmployeeDetailsCubit, EmployeeDetailsState>(
        listener: (context, state) {
          // Show error snackbar for action errors
          if (state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: AppColors.borderError,
              ),
            );
            context.read<EmployeeDetailsCubit>().clearActionStatus();
          }

          // Navigate back after successful delete
          if (state.isActionSuccess) {
            context.pop(true);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.borderError,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error ?? 'Failed to load employee details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.borderError,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<EmployeeDetailsCubit>()
                        .fetchEmployeeDetails(employeeId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final employee = state.employee;
          if (employee == null) {
            return const Center(child: Text('No data available'));
          }

          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      EmployeeHeader(
                        employee: employee,
                        isTogglingActive: state.isTogglingActive,
                        onToggleActive: (value) {
                          context
                              .read<EmployeeDetailsCubit>()
                              .toggleActiveStatus(employeeId, value);
                        },
                      ),
                      const SizedBox(height: 24),
                      // Employee information section
                      EmployeeInfoSection(employee: employee),
                      const SizedBox(height: 16),
                      // Documents section
                      EmployeeDocumentsSection(
                        documents: employee.documents,
                        onUpload: () {
                          // TODO: Implement document upload
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Send Message button
              Padding(
                padding: const EdgeInsets.all(16),
                child: GradientButton(
                  label: 'Sent Message',
                  onPressed: () {
                    // TODO: Implement send message
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onEdit(BuildContext context) async {
    final result = await context.push<bool>(
      Routes.editEmployee,
      extra: employeeId,
    );
    if (result == true && context.mounted) {
      context.read<EmployeeDetailsCubit>().fetchEmployeeDetails(employeeId);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    Helpers.showWarningBottomSheet(
      context,
      title: 'Delete Employee',
      message: 'Are you sure you want to delete this employee?',
      confirmText: 'Delete',
      onConfirm: () {
        context.read<EmployeeDetailsCubit>().deleteEmployee(employeeId);
      },
    );
  }
}
