import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/di.dart';
import '../../../../../../shared/styles/app_styles.dart';
import '../../../../blocs/academic_year/academic_year_cubit.dart';
import '../../../../blocs/academic_year/academic_year_state.dart';
import '../../../../models/academic_year_model.dart';
import '../../../../repositories/academic_year_repository.dart';
import 'widgets/academic_year_card.dart';
import 'widgets/create_academic_year_bottom_sheet.dart';

class AcademicYearTabView extends StatelessWidget {
  const AcademicYearTabView({super.key, required this.schoolId});

  final String schoolId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AcademicYearCubit(
        academicYearRepository: locator<AcademicYearRepository>(),
        schoolId: schoolId,
      )..fetchAcademicYears(),
      child: const _AcademicYearTabViewContent(),
    );
  }
}

class _AcademicYearTabViewContent extends StatefulWidget {
  const _AcademicYearTabViewContent();

  @override
  State<_AcademicYearTabViewContent> createState() =>
      _AcademicYearTabViewContentState();
}

class _AcademicYearTabViewContentState
    extends State<_AcademicYearTabViewContent> {
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
      context.read<AcademicYearCubit>().loadMoreAcademicYears();
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
    return BlocConsumer<AcademicYearCubit, AcademicYearState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.isActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Academic year saved successfully'),
              backgroundColor: AppColors.green,
            ),
          );
          context.read<AcademicYearCubit>().clearActionStatus();
        } else if (state.isActionFailure && state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.borderError,
            ),
          );
          context.read<AcademicYearCubit>().clearActionStatus();
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

  Widget _buildContent(AcademicYearState state) {
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
                  context.read<AcademicYearCubit>().fetchAcademicYears(),
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
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No academic years found.\nTap "Add Academic Year" to create one.',
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
      itemCount: state.academicYears.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= state.academicYears.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final academicYear = state.academicYears[index];
        return AcademicYearCard(
          academicYear: academicYear,
          onEdit: () => _onEditAcademicYear(academicYear),
          onDelete: () => _onDeleteAcademicYear(academicYear),
        );
      },
    );
  }

  Widget _buildBottomBar(AcademicYearState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: _AddAcademicYearButton(
          onTap: state.isActionLoading ? null : _onAddAcademicYear,
        ),
      ),
    );
  }

  Future<void> _onEditAcademicYear(AcademicYearModel academicYear) async {
    final result = await CreateAcademicYearBottomSheet.show(
      context,
      isEditing: true,
      initialName: academicYear.name,
      initialStartDate: academicYear.startDate,
      initialEndDate: academicYear.endDate,
      initialIsCurrent: academicYear.isCurrent,
    );

    if (result != null && mounted) {
      context.read<AcademicYearCubit>().updateAcademicYear(
        id: academicYear.id,
        name: result.name,
        startDate: result.startDate,
        endDate: result.endDate,
        isCurrent: result.isCurrent,
      );
    }
  }

  Future<void> _onDeleteAcademicYear(AcademicYearModel academicYear) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Academic Year'),
        content: Text(
          'Are you sure you want to delete "${academicYear.name}"?',
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
      context.read<AcademicYearCubit>().deleteAcademicYear(id: academicYear.id);
    }
  }

  Future<void> _onAddAcademicYear() async {
    final result = await CreateAcademicYearBottomSheet.show(context);

    if (result != null && mounted) {
      context.read<AcademicYearCubit>().createAcademicYear(
        name: result.name,
        startDate: result.startDate,
        endDate: result.endDate,
        isCurrent: result.isCurrent,
      );
    }
  }
}

class _AddAcademicYearButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddAcademicYearButton({this.onTap});

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
            'Add Academic Year',
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
