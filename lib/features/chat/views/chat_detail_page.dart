import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/di.dart';
import '../../../shared/styles/app_styles.dart';
import '../blocs/conversation/conversation_bloc.dart';
import '../repositories/chat_repository.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/chat_message_bubble.dart';

/// Arguments for the chat detail page.
class ChatDetailArgs {
  const ChatDetailArgs({
    required this.conversationId,
    required this.userName,
    this.userProfilePic,
  });

  final String conversationId;
  final String userName;
  final String? userProfilePic;

  factory ChatDetailArgs.fromMap(Map<String, dynamic> map) {
    return ChatDetailArgs(
      conversationId: map['conversationId'] as String,
      userName: map['userName'] as String,
      userProfilePic: map['userProfilePic'] as String?,
    );
  }
}

/// Chat detail page showing conversation with a user.
class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({super.key, required this.args});

  final ChatDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ConversationBloc(chatRepository: locator<ChatRepository>())..add(
            InitializeConversation(
              conversationId: args.conversationId,
              userName: args.userName,
              userProfilePic: args.userProfilePic,
            ),
          ),
      child: const _ChatDetailPageContent(),
    );
  }
}

class _ChatDetailPageContent extends StatefulWidget {
  const _ChatDetailPageContent();

  @override
  State<_ChatDetailPageContent> createState() => _ChatDetailPageContentState();
}

class _ChatDetailPageContentState extends State<_ChatDetailPageContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationBloc, ConversationState>(
      listener: (context, state) {
        // Handle errors
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<ConversationBloc>().add(const ClearConversationError());
        }

        // Scroll to bottom when new message is sent
        if (state.isSuccess && !state.isSending && state.messages.isNotEmpty) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: Column(
            children: [
              // Messages list
              Expanded(child: _buildMessagesList(state)),

              // Input field
              ChatInputField(
                isSending: state.isSending,
                onSend: (message) {
                  context.read<ConversationBloc>().add(SendMessage(message));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ConversationState state,
  ) {
    return AppBar(
      title: Row(
        children: [
          // Profile picture
          _buildAvatar(state.userName ?? '', state.userProfilePic),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.userName ?? 'Chat',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online', // This could be dynamic based on user status
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
      width: 44,
      height: 44,
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
                style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildMessagesList(ConversationState state) {
    // Loading state
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (state.messages.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textSecondary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        // Load more when scrolling to top (older messages)
        if (scrollInfo.metrics.pixels <= 100 &&
            !state.isLoadingMore &&
            state.hasNext) {
          context.read<ConversationBloc>().add(const LoadMoreMessages());
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: state.messages.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (state.isLoadingMore && index == 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final adjustedIndex = state.isLoadingMore ? index - 1 : index;
          final message = state.messages[adjustedIndex];

          // TODO: Replace with actual current user ID check
          // For now, we'll assume messages from the user we're chatting with are not "me"
          final isMe = message.senderId != state.userName;

          // Show sender info for first message or when sender changes
          final showSenderInfo =
              adjustedIndex == 0 ||
              state.messages[adjustedIndex - 1].senderId != message.senderId;

          return ChatMessageBubble(
            message: message,
            isMe: isMe,
            senderName: state.userName,
            senderProfilePic: state.userProfilePic,
            showSenderInfo: showSenderInfo && !isMe,
          );
        },
      ),
    );
  }
}
