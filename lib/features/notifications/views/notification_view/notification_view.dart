import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/di.dart';
import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../blocs/notification/notification_cubit.dart';
import '../../repositories/notification_repository.dart';
import 'widgets/add_notification_dialog.dart';
import 'widgets/notification_tile.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationCubit(repository: locator<NotificationRepository>())
            ..initialize(),
      child: const _NotificationViewContent(),
    );
  }
}

class _NotificationViewContent extends StatelessWidget {
  const _NotificationViewContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          // Show error snackbar when error occurs
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<NotificationCubit>().initialize();
                  },
                ),
              ),
            );
            context.read<NotificationCubit>().clearError();
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      floatingActionButton: MyFloatingActionButton(
        onPressed: () {
          AddNotificationDialog.show(context);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    // Initial loading state
    if (state.loadStatus == NotificationLoadStatus.loading &&
        state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state with no data
    if (state.loadStatus == NotificationLoadStatus.failure &&
        state.notifications.isEmpty) {
      return _buildErrorState(context, state.errorMessage);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationCubit>().refresh(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Filter chips
            _FilterChips(
              selectedFilter: state.selectedFilter,
              onFilterChanged: (filter) {
                context.read<NotificationCubit>().updateFilter(filter);
              },
            ),
            const SizedBox(height: 16),

            // Notifications list
            Expanded(
              child: state.filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : _NotificationsList(
                      notifications: state.filteredNotifications,
                      hasMore: state.hasMore,
                      isLoadingMore: state.isLoadingMore,
                      onLoadMore: () {
                        context.read<NotificationCubit>().loadMore();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<NotificationCubit>().initialize();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notifications list with pagination support.
class _NotificationsList extends StatefulWidget {
  const _NotificationsList({
    required this.notifications,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<NotificationModel> notifications;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  State<_NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<_NotificationsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom && widget.hasMore && !widget.isLoadingMore) {
      widget.onLoadMore();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger load more when 80% scrolled
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.notifications.length + (widget.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index == widget.notifications.length) {
          return _buildLoadingIndicator();
        }

        final notification = widget.notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () {
            // Handle notification tap
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: widget.isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// Filter chips for notification types.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final NotificationAudience selectedFilter;
  final ValueChanged<NotificationAudience> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: NotificationAudience.values
            .map(
              (audience) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: audience.label,
                  isSelected: selectedFilter == audience,
                  onTap: () => onFilterChanged(audience),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Individual filter chip.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
