import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../models/chat_models.dart';

/// A tile widget for displaying a chat user in the chat list.
class ChatUserTile extends StatelessWidget {
  const ChatUserTile({super.key, required this.user, required this.onTap});

  final ChatUserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile picture
            _buildAvatar(),
            const SizedBox(width: 12),

            // Name and last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: user.hasUnreadMessages
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.lastMessageText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.lastMessageText!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: user.hasUnreadMessages
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: user.hasUnreadMessages
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Time and unread count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (user.lastMessageTime != null)
                  Text(
                    _formatTime(user.lastMessageTime!),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (user.hasUnreadMessages) ...[
                  const SizedBox(height: 4),
                  _buildUnreadBadge(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withAlpha(20),
        image: user.profilePic != null
            ? DecorationImage(
                image: NetworkImage(user.profilePic!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: user.profilePic == null
          ? Center(
              child: Text(
                _getInitials(user.fullName),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.unreadCount > 99 ? '99+' : user.unreadCount.toString(),
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      return DateFormat('EEEE').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }
}
