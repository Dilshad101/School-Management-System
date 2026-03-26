import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/di.dart';
import '../../../../../../shared/styles/app_styles.dart';
import '../../../../blocs/subject/subject_cubit.dart';
import '../../../../blocs/subject/subject_state.dart';
import '../../../../models/subject_model.dart';
import '../../../../repositories/subject_repository.dart';
import 'widgets/create_subject_bottom_sheet.dart';
import 'widgets/subject_card.dart';

class SubjectTabView extends StatelessWidget {
  const SubjectTabView({super.key, required this.schoolId});

  final String schoolId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubjectCubit(
        subjectRepository: locator<SubjectRepository>(),
        schoolId: schoolId,
      )..fetchSubjects(),
      child: const _SubjectTabViewContent(),
    );
  }
}

class _SubjectTabViewContent extends StatefulWidget {
  const _SubjectTabViewContent();

  @override
  State<_SubjectTabViewContent> createState() => _SubjectTabViewContentState();
}

class _SubjectTabViewContentState extends State<_SubjectTabViewContent> {
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
      context.read<SubjectCubit>().loadMoreSubjects();
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
    return BlocConsumer<SubjectCubit, SubjectState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.isActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subject saved successfully'),
              backgroundColor: AppColors.green,
            ),
          );
          context.read<SubjectCubit>().clearActionStatus();
        } else if (state.isActionFailure && state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.borderError,
            ),
          );
          context.read<SubjectCubit>().clearActionStatus();
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

  Widget _buildContent(SubjectState state) {
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
              onPressed: () => context.read<SubjectCubit>().fetchSubjects(),
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
            Icon(Icons.book_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No subjects found.\nTap "Add Subject" to create one.',
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
      itemCount: state.subjects.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= state.subjects.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final subject = state.subjects[index];
        return SubjectCard(
          subject: subject,
          onEdit: () => _onEditSubject(subject),
          onDelete: () => _onDeleteSubject(subject),
        );
      },
    );
  }

  Widget _buildBottomBar(SubjectState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: _AddSubjectButton(
          onTap: state.isActionLoading ? null : _onAddSubject,
        ),
      ),
    );
  }

  Future<void> _onEditSubject(SubjectModel subject) async {
    final result = await CreateSubjectBottomSheet.show(
      context,
      isEditing: true,
      initialName: subject.name,
      initialCode: subject.code,
      initialIsLab: subject.isLab,
    );

    if (result != null && mounted) {
      context.read<SubjectCubit>().updateSubject(
        id: subject.id,
        name: result.name,
        code: result.code,
        isLab: result.isLab,
      );
    }
  }

  Future<void> _onDeleteSubject(SubjectModel subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject.name}"?'),
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
      context.read<SubjectCubit>().deleteSubject(id: subject.id);
    }
  }

  Future<void> _onAddSubject() async {
    final result = await CreateSubjectBottomSheet.show(context);

    if (result != null && mounted) {
      context.read<SubjectCubit>().createSubject(
        name: result.name,
        code: result.code,
        isLab: result.isLab,
      );
    }
  }
}

class _AddSubjectButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddSubjectButton({this.onTap});

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
            'Add Subject',
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
