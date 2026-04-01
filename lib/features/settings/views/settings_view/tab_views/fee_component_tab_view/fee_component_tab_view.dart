import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/auth/permissions.dart';
import 'package:school_management_system/shared/widgets/permission_builder.dart';

import '../../../../../../core/utils/di.dart';
import '../../../../../../shared/styles/app_styles.dart';
import '../../../../blocs/fee_component/fee_component_cubit.dart';
import '../../../../blocs/fee_component/fee_component_state.dart';
import '../../../../models/fee_component_model.dart';
import '../../../../repositories/fee_component_repository.dart';
import 'widgets/create_fee_component_bottom_sheet.dart';
import 'widgets/fee_component_card.dart';

class FeeComponentTabView extends StatelessWidget {
  const FeeComponentTabView({super.key, required this.schoolId});

  final String schoolId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeeComponentCubit(
        feeComponentRepository: locator<FeeComponentRepository>(),
        schoolId: schoolId,
      )..fetchFeeComponents(),
      child: const _FeeComponentTabViewContent(),
    );
  }
}

class _FeeComponentTabViewContent extends StatefulWidget {
  const _FeeComponentTabViewContent();

  @override
  State<_FeeComponentTabViewContent> createState() =>
      _FeeComponentTabViewContentState();
}

class _FeeComponentTabViewContentState
    extends State<_FeeComponentTabViewContent> {
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
      context.read<FeeComponentCubit>().loadMoreFeeComponents();
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
    return BlocConsumer<FeeComponentCubit, FeeComponentState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.isActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fee component saved successfully'),
              backgroundColor: AppColors.green,
            ),
          );
          context.read<FeeComponentCubit>().clearActionStatus();
        } else if (state.isActionFailure && state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.borderError,
            ),
          );
          context.read<FeeComponentCubit>().clearActionStatus();
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

  Widget _buildContent(FeeComponentState state) {
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
              onPressed: () =>
                  context.read<FeeComponentCubit>().fetchFeeComponents(),
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
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No fee components found.\nTap "Add Fee Component" to create one.',
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
      itemCount: state.feeComponents.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= state.feeComponents.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final feeComponent = state.feeComponents[index];
        return FeeComponentCard(
          feeComponent: feeComponent,
          onEdit: () => _onEditFeeComponent(feeComponent),
          onDelete: () => _onDeleteFeeComponent(feeComponent),
        );
      },
    );
  }

  Widget _buildBottomBar(FeeComponentState state) {
    return PermissionBuilder(
      permission: Permissions.changeFee,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: _AddFeeComponentButton(
            onTap: state.isActionLoading ? null : _onAddFeeComponent,
          ),
        ),
      ),
    );
  }

  Future<void> _onEditFeeComponent(FeeComponentModel feeComponent) async {
    final result = await CreateFeeComponentBottomSheet.show(
      context,
      isEditing: true,
      initialName: feeComponent.name,
      initialFrequency: feeComponent.frequency,
      initialIsOptional: feeComponent.isOptional,
    );

    if (result != null && mounted) {
      context.read<FeeComponentCubit>().updateFeeComponent(
        id: feeComponent.id,
        name: result.name,
        frequency: result.frequency,
        isOptional: result.isOptional,
      );
    }
  }

  Future<void> _onDeleteFeeComponent(FeeComponentModel feeComponent) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fee Component'),
        content: Text(
          'Are you sure you want to delete "${feeComponent.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.borderError),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<FeeComponentCubit>().deleteFeeComponent(id: feeComponent.id);
    }
  }

  Future<void> _onAddFeeComponent() async {
    final result = await CreateFeeComponentBottomSheet.show(context);

    if (result != null && mounted) {
      context.read<FeeComponentCubit>().createFeeComponent(
        name: result.name,
        frequency: result.frequency,
        isOptional: result.isOptional,
      );
    }
  }
}

class _AddFeeComponentButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddFeeComponentButton({this.onTap});

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
            'Add Fee Component',
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
