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
      'className': '10 - C',
      'classTeacher': 'Ananthu',
      'totalFees': '6,000',
      'paid': '4,000',
      'due': '2,000',
      'status': FeeStatus.partial,
    },
    {
      'className': '10 - C',
      'classTeacher': 'Ananthu',
      'totalFees': '6,000',
      'paid': '6,000',
      'due': '0',
      'status': FeeStatus.paid,
    },
    {
      'className': '10 - C',
      'classTeacher': 'Ananthu',
      'totalFees': '6,000',
      'paid': '6,000',
      'due': '0',
      'status': FeeStatus.paid,
    },
    {
      'className': '9 - A',
      'classTeacher': 'Priya',
      'totalFees': '5,500',
      'paid': '0',
      'due': '5,500',
      'status': FeeStatus.unpaid,
    },
    {
      'className': '8 - B',
      'classTeacher': 'Vikram',
      'totalFees': '5,000',
      'paid': '2,500',
      'due': '2,500',
      'status': FeeStatus.partial,
    },
    {
      'className': '7 - A',
      'classTeacher': 'Lakshmi',
      'totalFees': '4,500',
      'paid': '4,500',
      'due': '0',
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
                  className: data['className'],
                  classTeacher: data['classTeacher'],
                  totalFees: data['totalFees'],
                  paidAmount: data['paid'],
                  dueAmount: data['due'],
                  status: data['status'],
                  onTap: () {},
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
