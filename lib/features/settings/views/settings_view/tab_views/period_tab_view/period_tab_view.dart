import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/di.dart';
import '../../../../../../shared/styles/app_styles.dart';
import '../../../../blocs/period/period_cubit.dart';
import '../../../../blocs/period/period_state.dart';
import '../../../../repositories/period_repository.dart';
import 'widgets/create_period_bottom_sheet.dart';
import 'widgets/period_card.dart';

class PeriodTabView extends StatelessWidget {
  const PeriodTabView({super.key, required this.schoolId});

  final String schoolId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PeriodCubit(
        periodRepository: locator<PeriodRepository>(),
        schoolId: schoolId,
      )..fetchPeriods(),
      child: const _PeriodTabViewContent(),
    );
  }
}

class _PeriodTabViewContent extends StatefulWidget {
  const _PeriodTabViewContent();

  @override
  State<_PeriodTabViewContent> createState() => _PeriodTabViewContentState();
}

class _PeriodTabViewContentState extends State<_PeriodTabViewContent> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PeriodCubit>().loadMorePeriods();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PeriodCubit, PeriodState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.isActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Period saved successfully'),
              backgroundColor: AppColors.green,
            ),
          );
          context.read<PeriodCubit>().clearActionStatus();
        } else if (state.isActionFailure && state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.borderError,
            ),
          );
          context.read<PeriodCubit>().clearActionStatus();
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Column(
              children: [
                Expanded(child: _buildContent(state)),
                _buildBottomBar(state),
              ],
            ),
            if (state.isActionLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(PeriodState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
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
              onPressed: () => context.read<PeriodCubit>().fetchPeriods(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No periods found.\nTap "Add Period" to create one.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.periods.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= state.periods.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final period = state.periods[index];
        return PeriodCard(
          periodModel: period,
          onEdit: () => _onEditPeriod(period),
        );
      },
    );
  }

  Widget _buildBottomBar(PeriodState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: _AddPeriodButton(
          onTap: state.isActionLoading ? null : _onAddPeriod,
        ),
      ),
    );
  }

  Future<void> _onEditPeriod(dynamic period) async {
    final result = await CreatePeriodBottomSheet.show(
      context,
      isEditing: true,
      initialStartTime: period.startTime,
      initialEndTime: period.endTime,
      initialOrder: period.order,
    );

    if (result != null && mounted) {
      context.read<PeriodCubit>().updatePeriod(
        id: period.id,
        startTime: result.startTime,
        endTime: result.endTime,
        order: result.order ?? period.order,
      );
    }
  }

  Future<void> _onAddPeriod() async {
    final state = context.read<PeriodCubit>().state;
    final nextOrder = state.periods.isEmpty
        ? 1
        : state.periods.map((p) => p.order).reduce((a, b) => a > b ? a : b) + 1;

    final result = await CreatePeriodBottomSheet.show(
      context,
      initialOrder: nextOrder,
    );

    if (result != null && mounted) {
      context.read<PeriodCubit>().createPeriod(
        startTime: result.startTime,
        endTime: result.endTime,
        order: result.order ?? nextOrder,
      );
    }
  }
}

class _AddPeriodButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddPeriodButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Add Period',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
