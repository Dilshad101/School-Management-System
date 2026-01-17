import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../../shared/widgets/input_fields/search_field.dart';
import 'widgets/fee_summary_card.dart';
import 'widgets/fee_tile.dart';

class FeesView extends StatelessWidget {
  const FeesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
    final List<Map<String, dynamic>> feesData = [
      {
        'name': 'Priya',
        'class': '8 A',
        'id': 'ID 64452',
        'totalFees': '₹1,200',
        'paid': '₹1,200',
        'due': '₹0',
        'status': FeeStatus.paid,
      },
      {
        'name': 'Priya',
        'class': '8 A',
        'id': 'ID 64452',
        'totalFees': '₹1,200',
        'paid': '₹1,000',
        'due': '₹200',
        'status': FeeStatus.partial,
      },
      {
        'name': 'Priya',
        'class': '8 A',
        'id': 'ID 64452',
        'totalFees': '₹1,200',
        'paid': '₹1,200',
        'due': '₹0',
        'status': FeeStatus.paid,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Fees Management')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Summary cards - Row 1
            Row(
              children: [
                Expanded(
                  child: FeeSummaryCard(
                    label: 'Total Fee Structures',
                    value: '15',
                    percentageChange: '+1.2% this Year',
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FeeSummaryCard(
                    label: 'Total Payments Collected',
                    value: '₹50,000',
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
                  child: FeeSummaryCard(
                    label: 'Pending Dues',
                    value: '₹10,000',
                    percentageChange: '- 1.2% this Year',
                    isPositive: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FeeSummaryCard(
                    label: 'Overdue Fees',
                    value: '₹20,000',
                    percentageChange: '+1.2% this Year',
                    isPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search bar
            AppSearchBar(onChanged: (value) {}),
            const SizedBox(height: 10),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(label: 'All', isSelected: true),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: 'Paid', hasDropdown: true),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: 'Class', hasDropdown: true),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: 'Division', hasDropdown: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Fees list
            Expanded(
              child: ListView.separated(
                itemCount: feesData.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final data = feesData[index];
                  return FeeTile(
                    studentName: data['name'],
                    className: data['class'],
                    studentId: data['id'],
                    totalFees: data['totalFees'],
                    paidAmount: data['paid'],
                    dueAmount: data['due'],
                    status: data['status'],
                    onViewPressed: () {},
                    onPrintPressed: () {},
                    onAddPaymentPressed: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: () {}),
    );
  }

  Widget _buildFilterChip({
    required String label,
    bool isSelected = false,
    bool hasDropdown = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.border.withAlpha(180))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ],
        ],
      ),
    );
  }
}
