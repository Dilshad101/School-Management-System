import 'package:equatable/equatable.dart';

import '../../models/chat_models.dart';

/// Immutable state class for ConversationBloc.
class ConversationState extends Equatable {
  const ConversationState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSending = false,
    this.isSuccess = false,
    this.errorMessage,
    this.conversationId,
    this.userName,
    this.userProfilePic,
    this.messages = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  /// Loading state for initial fetch.
  final bool isLoading;

  /// Loading state for pagination.
  final bool isLoadingMore;

  /// Loading state for sending a message.
  final bool isSending;

  /// Success state after a successful operation.
  final bool isSuccess;

  /// Error message if an operation fails.
  final String? errorMessage;

  /// The conversation ID.
  final String? conversationId;

  /// The other user's name.
  final String? userName;

  /// The other user's profile picture.
  final String? userProfilePic;

  /// List of messages.
  final List<ChatMessageModel> messages;

  /// Current page number.
  final int currentPage;

  /// Total number of pages.
  final int totalPages;

  /// Total count of messages.
  final int totalCount;

  /// Whether there's a next page.
  final bool hasNext;

  /// Whether there's a previous page.
  final bool hasPrevious;

  /// Helper getters
  bool get hasError => errorMessage != null;
  bool get isEmpty => messages.isEmpty && !isLoading;
  bool get hasData => messages.isNotEmpty;
  bool get canLoadMore => hasNext && !isLoadingMore && !isLoading;
  bool get isInitialized => conversationId != null;

  /// Creates a copy of this state with the given fields replaced.
  ConversationState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSending,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
    String? conversationId,
    String? userName,
    String? userProfilePic,
    List<ChatMessageModel>? messages,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    return ConversationState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      conversationId: conversationId ?? this.conversationId,
      userName: userName ?? this.userName,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      messages: messages ?? this.messages,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    isSending,
    isSuccess,
    errorMessage,
    conversationId,
    userName,
    userProfilePic,
    messages,
    currentPage,
    totalPages,
    totalCount,
    hasNext,
    hasPrevious,
  ];
}
