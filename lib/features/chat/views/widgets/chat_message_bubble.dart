import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../models/chat_models.dart';

/// A bubble widget for displaying a chat message.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.senderName,
    this.senderProfilePic,
    this.showSenderInfo = true,
  });

  final ChatMessageModel message;
  final bool isMe;
  final String? senderName;
  final String? senderProfilePic;
  final bool showSenderInfo;

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return _buildMyMessage();
    } else {
      return _buildOtherMessage();
    }
  }

  Widget _buildMyMessage() {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withAlpha(180),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMessage() {
    final name = senderName ?? message.senderName ?? 'Unknown';
    final profilePic = senderProfilePic ?? message.senderProfilePic;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 48, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar
          if (showSenderInfo)
            _buildAvatar(name, profilePic)
          else
            const SizedBox(width: 40),
          const SizedBox(width: 8),

          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSenderInfo) ...[
                  Row(
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(message.timestamp),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    message.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? profilePic) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withAlpha(20),
        image: profilePic != null
            ? DecorationImage(
                image: NetworkImage(profilePic),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: profilePic == null
          ? Center(
              child: Text(
                _getInitials(name),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
}
