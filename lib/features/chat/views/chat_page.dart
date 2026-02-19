import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/utils/di.dart';
import '../../../shared/styles/app_styles.dart';
import '../../../shared/widgets/input_fields/search_field.dart';
import '../blocs/chat_list/chat_list_bloc.dart';
import '../repositories/chat_repository.dart';
import 'widgets/chat_filter_chip.dart';
import 'widgets/chat_user_tile.dart';

/// Main chat page showing list of chat contacts.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatListBloc(chatRepository: locator<ChatRepository>())
            ..add(const FetchChatUsers()),
      child: const _ChatPageContent(),
    );
  }
}

class _ChatPageContent extends StatefulWidget {
  const _ChatPageContent();

  @override
  State<_ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<_ChatPageContent> {
  int _selectedFilterIndex = 0;
  final _filters = const ['All', 'Employees', 'Guardians', 'Students'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: BlocConsumer<ChatListBloc, ChatListState>(
        listener: (context, state) {
          // Handle errors
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<ChatListBloc>().add(const ClearChatListError());
          }

          // Handle navigation after chat started
          if (state.hasChatStarted) {
            context.push(
              Routes.chatDetail,
              extra: {
                'conversationId': state.startedConversationId,
                'userName': state.startedUserName,
                'userProfilePic': state.startedUserProfilePic,
              },
            );
            context.read<ChatListBloc>().add(const ClearChatStarted());
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppSearchBar(
                  searchHint: 'Search here',
                  onChanged: (value) {
                    context.read<ChatListBloc>().add(SearchChatUsers(value));
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Filter chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ChatFilterChip(
                      label: _filters[index],
                      isSelected: _selectedFilterIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                        // TODO: Implement filtering by user type when API supports it
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Chat list
              Expanded(child: _buildChatList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatList(ChatListState state) {
    // Loading state
    if (state.isLoading && state.chatUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Starting chat loading overlay
    if (state.isStartingChat) {
      return Stack(
        children: [
          _buildUserList(state),
          Container(
            color: Colors.black.withAlpha(30),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    // Empty state
    if (state.chatUsers.isEmpty && !state.isLoading) {
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
              'No conversations yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.read<ChatListBloc>().add(const RefreshChatUsers());
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return _buildUserList(state);
  }

  Widget _buildUserList(ChatListState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatListBloc>().add(const RefreshChatUsers());
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200 &&
              !state.isLoadingMore &&
              state.hasNext) {
            context.read<ChatListBloc>().add(const LoadMoreChatUsers());
          }
          return false;
        },
        child: ListView.separated(
          itemCount: state.chatUsers.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) =>
              Divider(height: 1, indent: 80, color: AppColors.border),
          itemBuilder: (context, index) {
            // Loading more indicator
            if (index >= state.chatUsers.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final user = state.chatUsers[index];
            return ChatUserTile(
              user: user,
              onTap: () {
                context.read<ChatListBloc>().add(
                  StartChat(
                    userId: user.id,
                    userName: user.fullName,
                    userProfilePic: user.profilePic,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
