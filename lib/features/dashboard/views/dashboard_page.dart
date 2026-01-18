import 'package:flutter/material.dart';

import '../../../shared/styles/app_styles.dart';
import 'widgets/admission_tile.dart';
import 'widgets/attendance_chart.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_summary_card.dart';
import 'widgets/fee_collection_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          // const DashboardHeader(),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              // padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                                    value: '1200',
                                    iconPath: 'assets/icons/person.svg',
                                    percentageChange: '+1.2% this Year',
                                    isPositive: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DashboardSummaryCard(
                                    label: 'Total Employee',
                                    value: '1200',
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
                                    value: '1200',
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
                                    value: '1200',
                                    iconPath: 'assets/icons/fees.svg',
                                    percentageChange: '+1.2% this Year',
                                    isPositive: true,
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
                        const FeeCollectionChart(),
                        const SizedBox(height: 16),
                        // Attendance Chart
                        const AttendanceChart(),
                        const SizedBox(height: 24),
                        // New Admissions Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
  }
}
