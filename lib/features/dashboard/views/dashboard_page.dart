import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/di.dart';
import '../../../shared/styles/app_styles.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../repositories/dashboard_repository.dart';
import 'widgets/admission_tile.dart';
import 'widgets/attendance_chart.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_summary_card.dart';
import 'widgets/fee_collection_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardBloc(dashboardRepository: locator<DashboardRepository>())
            ..add(const DashboardFetchRequested()),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

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
                const DashboardRefreshRequested(),
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
                                      Expanded(
                                        child: DashboardSummaryCard(
                                          label: 'Total Students',
                                          value: state.isLoading
                                              ? '...'
                                              : '${state.studentCount}',
                                          iconPath: 'assets/icons/person.svg',
                                          percentageChange: '+1.2% this Year',
                                          isPositive: true,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: DashboardSummaryCard(
                                          label: 'Total Employee',
                                          value: state.isLoading
                                              ? '...'
                                              : '${state.employeeCount}',
                                          iconPath:
                                              'assets/icons/dashboard_employee.svg',
                                          percentageChange: '+1.2% this Year',
                                          isPositive: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Summary cards - Row 2
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DashboardSummaryCard(
                                          label: 'Total Attendance',
                                          value: '---',
                                          iconPath:
                                              'assets/icons/dashboard_calendar.svg',
                                          percentageChange: '+1.2% this Year',
                                          isPositive: true,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: DashboardSummaryCard(
                                          label: 'Pending Fees',
                                          value: state.isLoading
                                              ? '...'
                                              : state.formattedPendingFees,
                                          iconPath: 'assets/icons/fees.svg',
                                          percentageChange: '+1.2% this Year',
                                          isPositive:
                                              state.totalPendingFees <= 0,
                                        ),
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
                              // Fee Collection Chart
                              _buildFeeCollectionChart(state),
                              const SizedBox(height: 16),
                              // Attendance Chart
                              const AttendanceChart(),
                              const SizedBox(height: 24),
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
