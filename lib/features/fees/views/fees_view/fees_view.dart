import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../../shared/widgets/input_fields/search_field.dart';
import 'widgets/fee_summary_card.dart';
import 'widgets/fee_tile.dart';

class FeesView extends StatefulWidget {
  const FeesView({super.key});

  @override
  State<FeesView> createState() => _FeesViewState();
}

class _FeesViewState extends State<FeesView> {
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
    {
      'name': 'Rahul',
      'class': '8 B',
      'id': 'ID 64453',
      'totalFees': '₹1,500',
      'paid': '₹0',
      'due': '₹1,500',
      'status': FeeStatus.unpaid,
    },
    {
      'name': 'Anjali',
      'class': '9 A',
      'id': 'ID 64454',
      'totalFees': '₹1,200',
      'paid': '₹600',
      'due': '₹600',
      'status': FeeStatus.partial,
    },
    {
      'name': 'Vikram',
      'class': '10 A',
      'id': 'ID 64455',
      'totalFees': '₹1,800',
      'paid': '₹1,800',
      'due': '₹0',
      'status': FeeStatus.paid,
    },
  ];

  final _classes = const ['Class 1', 'Class 2', 'Class 3'];
  final _divisions = const ['Division A', 'Division B', 'Division C'];
  final _paymentStatuses = const ['Paid', 'Unpaid', 'Partial'];
  String? _selectedClass;
  String? _selectedDivision;
  String? _selectedPaymentStatus;

  late ValueNotifier<bool> _allSelectedNotifier;

  @override
  void initState() {
    super.initState();
    _selectedClass = _classes.isNotEmpty ? _classes.first : null;
    _selectedDivision = _divisions.isNotEmpty ? _divisions.first : null;
    _selectedPaymentStatus = 'Paid';
    _allSelectedNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _allSelectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration

    return Scaffold(
      appBar: AppBar(title: const Text('Fees Management')),
      body: CustomScrollView(
        slivers: [
          // Summary cards - Scrollable (hides on scroll)
          SliverToBoxAdapter(
            child: Padding(
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
                ],
              ),
            ),
          ),

          // Search bar and filter chips - Sticky header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const SizedBox(height: 8),
                    // Search bar
                    AppSearchBar(onChanged: (value) {}),
                    const SizedBox(height: 4),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ValueListenableBuilder(
                        valueListenable: _allSelectedNotifier,
                        builder: (context, value, child) {
                          return Row(
                            spacing: 8,
                            children: [
                              _buildAllChip(value),
                              FilterDropdown<String>(
                                items: _paymentStatuses,
                                value: _selectedPaymentStatus,
                                onChanged: (value) {
                                  print('payment status - $value');
                                  if (value == null) return;
                                  _selectedPaymentStatus = value;
                                  _allSelectedNotifier.value = false;
                                },
                                hintText: '',
                              ),
                              FilterDropdown<String>(
                                items: _classes,
                                value: _selectedClass,
                                onChanged: (value) {
                                  print('class - $value');
                                  if (value == null) return;
                                  _selectedClass = value;
                                  _allSelectedNotifier.value = false;
                                },
                                hintText: 'Class',
                              ),
                              FilterDropdown<String>(
                                items: _divisions,
                                value: _selectedDivision,
                                onChanged: (value) {
                                  print('division - $value');
                                  if (value == null) return;
                                  _selectedDivision = value;
                                  _allSelectedNotifier.value = false;
                                },
                                hintText: 'Division',
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // Fees list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList.separated(
              itemCount: feesData.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
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

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: () {}),
    );
  }

  Widget _buildAllChip(bool isSelected) {
    return InkWell(
      onTap: () {
        _allSelectedNotifier.value = true;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border.withAlpha(180)),
        ),
        child: Text(
          'All',
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Custom delegate for sticky header with fixed height
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 110;

  @override
  double get maxExtent => 110;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      elevation: overlapsContent || shrinkOffset > 0 ? 2 : 0,
      shadowColor: Colors.black26,
      color: AppColors.background,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
