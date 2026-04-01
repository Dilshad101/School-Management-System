import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/permissions.dart';
import '../../../core/utils/di.dart';
import '../../../shared/styles/app_styles.dart';
import '../../../shared/widgets/permission_builder/permission_builder.dart';
import '../../auth/blocs/user/user_bloc.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../repositories/dashboard_repository.dart';
import 'widgets/admission_tile.dart';
import 'widgets/attendance_chart.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_summary_card.dart';
import 'widgets/fee_collection_chart.dart';
import 'widgets/recently_paid_section.dart';
import 'widgets/timetable_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user permissions to pass to DashboardBloc
    final userPermissions =
        context.read<UserBloc>().state.user?.permissions ?? [];

    return BlocProvider(
      create: (context) =>
          DashboardBloc(dashboardRepository: locator<DashboardRepository>())
            ..add(DashboardFetchRequested(permissions: userPermissions)),
      child: _DashboardContent(permissions: userPermissions),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.permissions});

  final List<String> permissions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<DashboardBloc>().add(const DashboardErrorCleared());
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                DashboardRefreshRequested(permissions: permissions),
              );
            },
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards - Row 1
                        Stack(
                          children: [
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).padding.top,
                                  ),
                                  const DashboardHeader(),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      // Total Students - requires view_student permission
                                      PermissionBuilder(
                                        permission: Permissions.viewStudent,
                                        builder: (context, hasPermission) {
                                          if (!hasPermission) {
                                            return const SizedBox.shrink();
                                          }
                                          return Expanded(
                                            child: DashboardSummaryCard(
                                              label: 'Total Students',
                                              value: state.isLoading
                                                  ? '...'
                                                  : '${state.studentCount}',
                                              iconPath:
                                                  'assets/icons/person.svg',
                                              percentageChange:
                                                  '+1.2% this Year',
                                              isPositive: true,
                                            ),
                                          );
                                        },
                                      ),
                                      PermissionBuilder(
                                        permission: Permissions.viewStudent,
                                        child: const SizedBox(width: 10),
                                      ),

                                      // Total Employee - requires view_user permission
                                      PermissionBuilder(
                                        permission: Permissions.viewUser,
                                        builder: (context, hasPermission) {
                                          if (!hasPermission) {
                                            return const SizedBox.shrink();
                                          }
                                          return Expanded(
                                            child: DashboardSummaryCard(
                                              label: 'Total Employee',
                                              value: state.isLoading
                                                  ? '...'
                                                  : '${state.employeeCount}',
                                              iconPath:
                                                  'assets/icons/dashboard_employee.svg',
                                              percentageChange:
                                                  '+1.2% this Year',
                                              isPositive: true,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Summary cards - Row 2
                                  Row(
                                    children: [
                                      // Total Attendance - requires view_attendance permission
                                      PermissionBuilder(
                                        permission: Permissions.viewAttendance,
                                        builder: (context, hasPermission) {
                                          if (!hasPermission) {
                                            return const SizedBox.shrink();
                                          }
                                          return Expanded(
                                            child: DashboardSummaryCard(
                                              label: 'Total Attendance',
                                              value: '---',
                                              iconPath:
                                                  'assets/icons/dashboard_calendar.svg',
                                              percentageChange:
                                                  '+1.2% this Year',
                                              isPositive: true,
                                            ),
                                          );
                                        },
                                      ),
                                      PermissionBuilder(
                                        permission: Permissions.viewAttendance,
                                        child: const SizedBox(width: 10),
                                      ),
                                      // Pending Fees - requires view_fee permission
                                      PermissionBuilder(
                                        permission: Permissions.viewReports,
                                        builder: (context, hasPermission) {
                                          if (!hasPermission) {
                                            return const SizedBox.shrink();
                                          }
                                          return Expanded(
                                            child: DashboardSummaryCard(
                                              label: 'Pending Fees',
                                              value: state.isLoading
                                                  ? '...'
                                                  : state.formattedPendingFees,
                                              iconPath: 'assets/icons/fees.svg',
                                              percentageChange:
                                                  '+1.2% this Year',
                                              isPositive:
                                                  state.totalPendingFees <= 0,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              // Overview section
                              Text(
                                'Overview',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Fee Collection Chart - requires view_fee permission
                              PermissionBuilder(
                                permission: Permissions.viewReports,
                                child: Column(
                                  children: [
                                    _buildFeeCollectionChart(state),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                              // Attendance Chart - requires view_attendance permission
                              PermissionBuilder(
                                permission: Permissions.viewAttendance,
                                child: Column(
                                  children: [
                                    const AttendanceChart(),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                              // Timetable Section - requires view_timetable permission
                              PermissionBuilder(
                                permissions: [
                                  Permissions.viewTimetable,
                                  Permissions.viewTeacherTimetable,
                                ],
                                child: Column(
                                  children: [
                                    TimetableSection(
                                      periods: state.periods,
                                      isLoading: state.isLoading,
                                      onViewAll: () {
                                        // TODO: Navigate to timetable page
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                              // Recently Paid Section - requires view_fee or view_student_fee_history
                              PermissionBuilder(
                                permissions: [
                                  Permissions.viewFee,
                                  Permissions.viewStudentFeeHistory,
                                ],
                                child: Column(
                                  children: [
                                    RecentlyPaidSection(
                                      payments: state.recentPayments,
                                      isLoading: state.isLoading,
                                      onViewAll: () {
                                        // TODO: Navigate to fees page
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                              // New Admissions Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'New Admissions Status',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'View All',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Admission tiles
                              const AdmissionTile(
                                studentName: 'Priya',
                                className: '8 A',
                                studentId: 'ID 64452',
                                status: AdmissionStatus.pending,
                              ),
                              const AdmissionTile(
                                studentName: 'Priya',
                                className: '8 A',
                                studentId: 'ID 64452',
                                status: AdmissionStatus.pending,
                              ),
                              const AdmissionTile(
                                studentName: 'Priya',
                                className: '8 A',
                                studentId: 'ID 64452',
                                status: AdmissionStatus.approved,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeeCollectionChart(DashboardState state) {
    if (state.isLoading) {
      return const FeeCollectionChart(isLoading: true);
    }

    final payments = state.lastSixMonthsPayments;
    if (payments == null || payments.months.isEmpty) {
      return const FeeCollectionChart();
    }

    // Convert API data to chart data
    final chartData = payments.months.map((monthData) {
      return FeeCollectionData(
        month: monthData.monthName,
        bankAmount: monthData.bankAmount,
        cashAmount: monthData.cashAmount,
      );
    }).toList();

    return FeeCollectionChart(data: chartData);
  }
}

var userDetailsResponse = {
  "success": true,
  "data": {
    "id": "09ce4a95-56ac-4ea0-95d8-418189aee3bd",
    "email": "mcaeo92595@minitts.net",
    "phone": "7894561212",
    "first_name": "dilshad",
    "last_name": null,
    "is_platform_admin": false,
    "is_active": true,
    "role": [
      {
        "id": "6ca492ba-23f3-4ea4-9632-df10c7e879bc",
        "user": "09ce4a95-56ac-4ea0-95d8-418189aee3bd",
        "school": "accec208-5989-4f96-855f-3b57afd98634",
        "roles": ["99ca7e8f-a26f-4f46-97fa-09925d69d096"],
        "role_names": ["Admin"],
        "status": "active",
        "joined_at": "2026-03-26T06:47:57.034501Z",
        "common_id": null,
      },
    ],
    "permission": [
      "change_school_type",
      "view_guardian_timetable",
      "delete_device",
      "view_exam",
      "change_user",
      "activate_user",
      "change_role",
      "delete_period",
      "manage_school_settings",
      "manage_attendance_events",
      "view_chat",
      "view_academic_year",
      "delete_subscription",
      "add_device",
      "delete_academic_year",
      "delete_feature",
      "view_subject",
      "view_attendance",
      "manage_attendance_sources",
      "add_academic_year",
      "view_audit_logs",
      "assign_role",
      "view_teacher_timetable",
      "view_notification",
      "add_transport",
      "change_period",
      "add_role",
      "view_student_fee_history",
      "view_school",
      "view_student_timetable",
      "change_notification",
      "view_timetable",
      "change_guardian",
      "deactivate_user",
      "view_student",
      "delete_student",
      "view_user_school",
      "change_subscription",
      "view_student_fee_details",
      "change_feature",
      "view_subscription",
      "change_timetable",
      "change_academic_year",
      "view_reports",
      "view_profile",
      "add_classroom",
      "view_timetable_availability",
      "view_user",
      "mark_attendance",
      "add_period",
      "view_feature",
      "delete_guardian",
      "add_timetable",
      "delete_user_school",
      "add_feature",
      "add_user",
      "add_plan",
      "delete_school",
      "delete_school_type",
      "add_exam",
      "change_school",
      "add_subscription",
      "delete_subject",
      "collect_payment",
      "delete_user",
      "view_student_transport_status",
      "change_transport",
      "delete_timetable",
      "add_user_school",
      "change_fee",
      "add_marks",
      "change_subject",
      "add_guardian",
      "delete_plan",
      "change_classroom",
      "add_transport_event",
      "add_school_type",
      "delete_notification",
      "change_device",
      "change_user_school",
      "view_fee",
      "delete_classroom",
      "change_plan",
      "delete_transport",
      "correct_attendance",
      "view_device",
      "view_transport",
      "send_notification",
      "view_role",
      "view_classroom",
      "delete_role",
      "add_student",
      "publish_marks",
      "send_message",
      "view_guardian",
      "view_school_type",
      "view_plan",
      "add_school",
      "view_permission",
      "view_marks",
      "publish_exam",
      "change_student",
      "export_attendance",
      "promote_student",
      "export_reports",
      "view_period",
      "access_admin_dashboard",
      "manage_attendance_identifiers",
      "refund_payment",
      "add_subject",
    ],
    "schools": [
      {
        "id": "6ca492ba-23f3-4ea4-9632-df10c7e879bc",
        "user": "09ce4a95-56ac-4ea0-95d8-418189aee3bd",
        "school": "accec208-5989-4f96-855f-3b57afd98634",
        "roles": ["99ca7e8f-a26f-4f46-97fa-09925d69d096"],
        "role_names": ["Admin"],
        "status": "active",
        "joined_at": "2026-03-26T06:47:57.034501Z",
        "common_id": null,
      },
    ],
    "is_superuser": false,
    "current_classroom_details": null,
  },
  "meta": {
    "request_id": "cf063020-1d54-41a9-b2fb-2284c5bb1a10",
    "timestamp": "2026-03-31T06:15:42.292391+00:00",
    "debug": {"required_permission": null},
  },
};
