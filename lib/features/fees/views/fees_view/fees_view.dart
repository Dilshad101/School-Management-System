import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tenant/tenant_context.dart';
import '../../../../core/utils/di.dart';
import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../../shared/widgets/input_fields/search_field.dart';
import '../../blocs/fees/fees_bloc.dart';
import '../../blocs/fees/fees_event.dart';
import '../../blocs/fees/fees_state.dart';
import '../../models/student_fee_model.dart';
import '../../repositories/fees_repository.dart';
import 'widgets/add_payment_bottom_sheet.dart';
import 'widgets/create_fee_bottom_sheet.dart';
import 'widgets/fee_summary_card.dart';
import 'widgets/fee_tile.dart';

class FeesView extends StatelessWidget {
  const FeesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FeesBloc(feesRepository: locator<FeesRepository>())
            ..add(const FeesFetchRequested()),
      child: const _FeesViewContent(),
    );
  }
}

class _FeesViewContent extends StatefulWidget {
  const _FeesViewContent();

  @override
  State<_FeesViewContent> createState() => _FeesViewContentState();
}

class _FeesViewContentState extends State<_FeesViewContent> {
  final _classes = const ['Class 1', 'Class 2', 'Class 3'];
  final _divisions = const ['Division A', 'Division B', 'Division C'];
  final _paymentStatuses = const ['Paid', 'Unpaid', 'Partial'];
  String? _selectedClass;
  String? _selectedDivision;
  String? _selectedPaymentStatus;

  late ValueNotifier<bool> _allSelectedNotifier;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedClass = _classes.isNotEmpty ? _classes.first : null;
    _selectedDivision = _divisions.isNotEmpty ? _divisions.first : null;
    _selectedPaymentStatus = 'Paid';
    _allSelectedNotifier = ValueNotifier<bool>(true);
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _allSelectedNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<FeesBloc>().add(const FeesLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    context.read<FeesBloc>().add(FeesSearchRequested(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fees Management')),
      body: CustomScrollView(
        controller: _scrollController,
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
                    // Search bar
                    AppSearchBar(onChanged: _onSearchChanged),
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

          // Fees list with BLoC
          BlocConsumer<FeesBloc, FeesState>(
            listenWhen: (previous, current) =>
                previous.error != current.error && current.error != null,
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: AppColors.borderError,
                  ),
                );
                context.read<FeesBloc>().add(const FeesErrorCleared());
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${state.error}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.borderError,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<FeesBloc>().add(
                              const FeesFetchRequested(refresh: true),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.isSearching
                              ? 'No fees found for "${state.searchQuery}"'
                              : 'No fees found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList.separated(
                  itemCount: state.fees.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >= state.fees.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final fee = state.fees[index];
                    return FeeTile(
                      fee: fee,
                      onTap: () {
                        // TODO: Navigate to fee details
                      },
                      onAddPayment: () => _onAddPayment(fee),
                    );
                  },
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: _onCreateFee),
    );
  }

  Future<void> _onCreateFee() async {
    final schoolId = _getSchoolId();
    if (schoolId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('School not selected')));
      return;
    }

    final result = await CreateFeeBottomSheet.show(context, schoolId: schoolId);
    if (result == true && mounted) {
      // Refresh the fees list
      context.read<FeesBloc>().add(const FeesFetchRequested(refresh: true));
    }
  }

  Future<void> _onAddPayment(StudentFeeModel fee) async {
    final result = await AddPaymentBottomSheet.show(context, fee);
    if (result == true && mounted) {
      // Refresh the fees list after successful payment
      context.read<FeesBloc>().add(const FeesFetchRequested(refresh: true));
    }
  }

  String _getSchoolId() {
    final session = locator<SessionHolder>().session;
    if (session?.schoolId != null && session!.schoolId!.isNotEmpty) {
      return session.schoolId!;
    }
    return locator<TenantContext>().selectedSchoolId ?? '';
  }

  Widget _buildAllChip(bool isSelected) {
    return InkWell(
      onTap: () {
        _allSelectedNotifier.value = true;
        context.read<FeesBloc>().add(const FeesSearchCleared());
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
