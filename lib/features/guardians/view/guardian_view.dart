import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/utils/helpers.dart';
import 'package:school_management_system/features/guardians/blocs/blocs.dart';
import 'package:school_management_system/features/guardians/view/widgets/guardian_tile.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/floating_action_button.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/utils/di.dart';
import '../../../shared/widgets/dropdowns/filter_dropdown.dart';
import '../../../shared/widgets/input_fields/search_field.dart';
import '../models/guardian_model.dart';
import '../repositories/guardians_repository.dart';

class GuardianView extends StatelessWidget {
  const GuardianView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GuardiansBloc(guardiansRepository: locator<GuardiansRepository>())
            ..add(const GuardiansFetchRequested()),
      child: const _GuardianViewContent(),
    );
  }
}

class _GuardianViewContent extends StatefulWidget {
  const _GuardianViewContent();

  @override
  State<_GuardianViewContent> createState() => _GuardianViewContentState();
}

class _GuardianViewContentState extends State<_GuardianViewContent> {
  final _classes = const ['Class 1', 'Class 2', 'Class 3'];
  final _divisions = const ['Division A', 'Division B', 'Division C'];

  String? _selectedClass;
  String? _selectedDivision;

  late ValueNotifier<bool> _allSelectedNotifier;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedClass = _classes.isNotEmpty ? _classes.first : null;
    _selectedDivision = _divisions.isNotEmpty ? _divisions.first : null;
    _allSelectedNotifier = ValueNotifier<bool>(true);
    _scrollController = ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<GuardiansBloc>().add(const GuardiansLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _allSelectedNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToAddGuardian() async {
    final guardiansBloc = context.read<GuardiansBloc>();

    final result = await context.push<bool>(Routes.createGuardian);

    if (result == true && mounted) {
      guardiansBloc.add(const GuardianAddedSuccessfully());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardians')),
      body: BlocConsumer<GuardiansBloc, GuardiansState>(
        listener: (context, state) {
          // Show error snackbar
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            context.read<GuardiansBloc>().add(const GuardiansErrorCleared());
          }

          // Show success message
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.green,
                ),
              );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Search bar with filter button
                AppSearchBar(
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<GuardiansBloc>().add(
                        const GuardiansSearchCleared(),
                      );
                    } else {
                      context.read<GuardiansBloc>().add(
                        GuardiansSearchRequested(query: value),
                      );
                    }
                  },
                ),

                const SizedBox(height: 10),

                // filter and sort options
                ValueListenableBuilder(
                  valueListenable: _allSelectedNotifier,
                  builder: (context, value, child) {
                    return Row(
                      spacing: 8,
                      children: [
                        _buildAllChip(value),
                        FilterDropdown<String>(
                          items: _classes,
                          value: _selectedClass,
                          onChanged: (value) {
                            if (value == null) return;
                            _selectedClass = value;
                            _allSelectedNotifier.value = false;
                            context.read<GuardiansBloc>().add(
                              GuardiansClassFilterChanged(classId: value),
                            );
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
                            context.read<GuardiansBloc>().add(
                              GuardiansDivisionFilterChanged(divisionId: value),
                            );
                          },
                          hintText: 'Division',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Content based on state
                Expanded(child: _buildContent(state)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: MyFloatingActionButton(
        onPressed: _navigateToAddGuardian,
      ),
    );
  }

  Widget _buildContent(GuardiansState state) {
    // Initial loading state
    if (state.isLoading && state.guardians.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Error state with no data
    if (state.hasError && state.guardians.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              state.error ?? 'Failed to load guardians',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<GuardiansBloc>().add(
                  const GuardiansFetchRequested(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              state.isSearching
                  ? 'No guardians found for "${state.searchQuery}"'
                  : 'No guardians found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new guardian',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // List with data
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<GuardiansBloc>().add(
          const GuardiansFetchRequested(refresh: true),
        );
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.guardians.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          // Loading indicator at bottom
          if (index >= state.guardians.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final guardian = state.guardians[index];
          return GuardianTile(
            guardian: guardian,
            onTap: () => _onGuardianTap(guardian),
            onEdit: () => _onEditGuardian(guardian),
            onDelete: () => _onDeleteGuardian(guardian),
          );
        },
      ),
    );
  }

  void _onGuardianTap(GuardianModel guardian) {
    // Navigate to guardian details (same as edit for now)
    _onEditGuardian(guardian);
  }

  void _onEditGuardian(GuardianModel guardian) async {
    final guardiansBloc = context.read<GuardiansBloc>();

    final result = await context.push<bool>(
      Routes.editGuardian.replaceFirst(':id', guardian.id),
    );

    if (result == true && mounted) {
      guardiansBloc.add(const GuardiansFetchRequested(refresh: true));
    }
  }

  void _onDeleteGuardian(GuardianModel guardian) {
    Helpers.showWarningBottomSheet(
      context,
      title: 'Delete Guardian',
      message: 'Are you sure you want to delete ${guardian.displayName}?',
      onConfirm: () {
        context.read<GuardiansBloc>().add(
          GuardianDeleteRequested(guardianId: guardian.id),
        );
      },
      confirmText: 'Delete',
    );
  }

  Widget _buildAllChip(bool isSelected) {
    return InkWell(
      onTap: () {
        _allSelectedNotifier.value = true;
        context.read<GuardiansBloc>().add(const GuardiansFiltersCleared());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
