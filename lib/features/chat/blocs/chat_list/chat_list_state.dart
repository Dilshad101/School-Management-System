import 'package:equatable/equatable.dart';

import '../../models/chat_models.dart';

/// Immutable state class for ChatListBloc.
class ChatListState extends Equatable {
  const ChatListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isStartingChat = false,
    this.isSuccess = false,
    this.errorMessage,
    this.chatUsers = const [],
    this.searchQuery = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasNext = false,
    this.hasPrevious = false,
    this.startedConversationId,
    this.startedUserName,
    this.startedUserProfilePic,
  });

  /// Loading state for initial fetch.
  final bool isLoading;

  /// Loading state for pagination.
  final bool isLoadingMore;

  /// Loading state for pull-to-refresh.
  final bool isRefreshing;

  /// Loading state for starting a chat.
  final bool isStartingChat;

  /// Success state after a successful operation.
  final bool isSuccess;

  /// Error message if an operation fails.
  final String? errorMessage;

  /// List of chat users.
  final List<ChatUserModel> chatUsers;

  /// Current search query.
  final String searchQuery;

  /// Current page number.
  final int currentPage;

  /// Total number of pages.
  final int totalPages;

  /// Total count of chat users.
  final int totalCount;

  /// Whether there's a next page.
  final bool hasNext;

  /// Whether there's a previous page.
  final bool hasPrevious;

  /// The conversation ID after starting a chat (used for navigation).
  final String? startedConversationId;

  /// The user name for the started conversation.
  final String? startedUserName;

  /// The user profile pic for the started conversation.
  final String? startedUserProfilePic;

  /// Helper getters
  bool get hasError => errorMessage != null;
  bool get isEmpty => chatUsers.isEmpty && !isLoading;
  bool get hasData => chatUsers.isNotEmpty;
  bool get canLoadMore => hasNext && !isLoadingMore && !isLoading;
  bool get hasChatStarted => startedConversationId != null;

  /// Creates a copy of this state with the given fields replaced.
  ChatListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isStartingChat,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
    List<ChatUserModel>? chatUsers,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasNext,
    bool? hasPrevious,
    String? startedConversationId,
    bool clearStartedChat = false,
    String? startedUserName,
    String? startedUserProfilePic,
  }) {
    return ChatListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isStartingChat: isStartingChat ?? this.isStartingChat,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      chatUsers: chatUsers ?? this.chatUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      startedConversationId: clearStartedChat
          ? null
          : (startedConversationId ?? this.startedConversationId),
      startedUserName: clearStartedChat
          ? null
          : (startedUserName ?? this.startedUserName),
      startedUserProfilePic: clearStartedChat
          ? null
          : (startedUserProfilePic ?? this.startedUserProfilePic),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    isRefreshing,
    isStartingChat,
    isSuccess,
    errorMessage,
    chatUsers,
    searchQuery,
    currentPage,
    totalPages,
    totalCount,
    hasNext,
    hasPrevious,
    startedConversationId,
    startedUserName,
    startedUserProfilePic,
  ];
}
