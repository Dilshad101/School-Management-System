import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../../../shared/widgets/buttons/floating_action_button.dart';
import '../../blocs/notification/notification_cubit.dart';
import 'widgets/add_notification_dialog.dart';
import 'widgets/notification_tile.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationCubit()..initialize(),
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
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
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
                      : ListView.separated(
                          itemCount: state.filteredNotifications.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final notification =
                                state.filteredNotifications[index];
                            return NotificationTile(
                              notification: notification,
                              onTap: () {
                                // Handle notification tap
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: MyFloatingActionButton(
        onPressed: () {
          AddNotificationDialog.show(context);
        },
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
