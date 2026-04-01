import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/auth/permissions.dart';
import 'package:school_management_system/shared/widgets/permission_builder/permission_builder.dart';

import '../../../../../../core/utils/di.dart';
import '../../../../../../shared/styles/app_styles.dart';
import '../../../../blocs/fee_structure/fee_structure_cubit.dart';
import '../../../../blocs/fee_structure/fee_structure_state.dart';
import '../../../../models/fee_structure_model.dart';
import '../../../../repositories/fee_structure_repository.dart';
import 'widgets/create_fee_structure_bottom_sheet.dart';
import 'widgets/fee_structure_card.dart';

class FeeStructureTabView extends StatelessWidget {
  const FeeStructureTabView({super.key, required this.schoolId});

  final String schoolId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeeStructureCubit(
        feeStructureRepository: locator<FeeStructureRepository>(),
        schoolId: schoolId,
      )..fetchFeeStructures(),
      child: _FeeStructureTabViewContent(schoolId: schoolId),
    );
  }
}

class _FeeStructureTabViewContent extends StatefulWidget {
  const _FeeStructureTabViewContent({required this.schoolId});

  final String schoolId;

  @override
  State<_FeeStructureTabViewContent> createState() =>
      _FeeStructureTabViewContentState();
}

class _FeeStructureTabViewContentState
    extends State<_FeeStructureTabViewContent> {
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
      context.read<FeeStructureCubit>().loadMoreFeeStructures();
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
    return BlocConsumer<FeeStructureCubit, FeeStructureState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.isActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fee structure saved successfully'),
              backgroundColor: AppColors.green,
            ),
          );
          context.read<FeeStructureCubit>().clearActionStatus();
        } else if (state.isActionFailure && state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.borderError,
            ),
          );
          context.read<FeeStructureCubit>().clearActionStatus();
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

  Widget _buildContent(FeeStructureState state) {
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
                  context.read<FeeStructureCubit>().fetchFeeStructures(),
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
              'No fee structures found.\nTap "Add Fee Structure" to create one.',
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
      itemCount: state.feeStructures.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= state.feeStructures.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final feeStructure = state.feeStructures[index];
        return FeeStructureCard(
          feeStructure: feeStructure,
          onEdit: () => _onEditFeeStructure(feeStructure),
          onDelete: () => _onDeleteFeeStructure(feeStructure),
        );
      },
    );
  }

  Widget _buildBottomBar(FeeStructureState state) {
    return PermissionBuilder(
      permission: Permissions.changeFee,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: _AddFeeStructureButton(
            onTap: state.isActionLoading ? null : _onAddFeeStructure,
          ),
        ),
      ),
    );
  }

  Future<void> _onEditFeeStructure(FeeStructureModel feeStructure) async {
    final result = await CreateFeeStructureBottomSheet.show(
      context,
      schoolId: widget.schoolId,
      isEditing: true,
      initialName: feeStructure.name,
      initialClassroomId: feeStructure.classroomDetails.id,
      initialClassroomName: feeStructure.classroomDetails.name,
      initialAcademicYearId: feeStructure.academicYearDetails.id,
      initialAcademicYearName: feeStructure.academicYearDetails.name,
      initialItems: feeStructure.items
          .map(
            (item) => FeeComponentItem(
              componentId: item.componentId,
              componentName: item.componentName,
              amount: item.totalAmount,
            ),
          )
          .toList(),
    );

    if (result != null && mounted) {
      context.read<FeeStructureCubit>().updateFeeStructure(
        id: feeStructure.id,
        name: result.name,
        classroomId: result.classroomId,
        academicYearId: result.academicYearId,
        items: result.items
            .map(
              (item) => {
                'component': item.componentId,
                'total_amount': item.amount,
              },
            )
            .toList(),
      );
    }
  }

  Future<void> _onDeleteFeeStructure(FeeStructureModel feeStructure) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fee Structure'),
        content: Text(
          'Are you sure you want to delete "${feeStructure.name}"?',
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
      context.read<FeeStructureCubit>().deleteFeeStructure(id: feeStructure.id);
    }
  }

  Future<void> _onAddFeeStructure() async {
    final result = await CreateFeeStructureBottomSheet.show(
      context,
      schoolId: widget.schoolId,
    );

    if (result != null && mounted) {
      context.read<FeeStructureCubit>().createFeeStructure(
        name: result.name,
        classroomId: result.classroomId,
        academicYearId: result.academicYearId,
        items: result.items
            .map(
              (item) => {
                'component': item.componentId,
                'total_amount': item.amount,
              },
            )
            .toList(),
      );
    }
  }
}

class _AddFeeStructureButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddFeeStructureButton({this.onTap});

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
            'Add Fee Structure',
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
