import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/chat_repository.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

export 'chat_list_event.dart';
export 'chat_list_state.dart';

/// BLoC for managing the chat users list state.
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatListState()) {
    on<FetchChatUsers>(_onFetchChatUsers);
    on<SearchChatUsers>(_onSearchChatUsers);
    on<LoadMoreChatUsers>(_onLoadMoreChatUsers);
    on<RefreshChatUsers>(_onRefreshChatUsers);
    on<StartChat>(_onStartChat);
    on<ClearChatStarted>(_onClearChatStarted);
    on<ClearChatListError>(_onClearError);
  }

  final ChatRepository _chatRepository;

  /// Debounce timer for search
  Timer? _searchDebounce;

  /// Handles fetching chat users.
  Future<void> _onFetchChatUsers(
    FetchChatUsers event,
    Emitter<ChatListState> emit,
  ) async {
    // Don't show loading if refreshing
    if (!event.refresh) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final response = await _chatRepository.getChatUsers(
        page: event.page,
        search: event.search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: true,
          chatUsers: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasNext: response.hasNext,
          hasPrevious: response.hasPrevious,
          searchQuery: event.search ?? state.searchQuery,
        ),
      );
    } on ApiException catch (e, s) {
      log('FetchChatUsers error: $e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e, s) {
      log('FetchChatUsers error: $e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: false,
          errorMessage: 'Failed to fetch chat users. Please try again.',
        ),
      );
    }
  }

  /// Handles searching chat users with debounce.
  Future<void> _onSearchChatUsers(
    SearchChatUsers event,
    Emitter<ChatListState> emit,
  ) async {
    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    // Update search query immediately for UI feedback
    emit(state.copyWith(searchQuery: event.query));

    // Debounce the actual search
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(FetchChatUsers(page: 1, search: event.query));
    });
  }

  /// Handles loading more chat users (pagination).
  Future<void> _onLoadMoreChatUsers(
    LoadMoreChatUsers event,
    Emitter<ChatListState> emit,
  ) async {
    // Don't load more if already loading or no more pages
    if (!state.canLoadMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _chatRepository.getChatUsers(
        page: nextPage,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      // Append new users to existing list
      final updatedUsers = [...state.chatUsers, ...response.results];

      emit(
        state.copyWith(
          isLoadingMore: false,
          chatUsers: updatedUsers,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasNext: response.hasNext,
          hasPrevious: response.hasPrevious,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Failed to load more users.',
        ),
      );
    }
  }

  /// Handles refreshing chat users list.
  Future<void> _onRefreshChatUsers(
    RefreshChatUsers event,
    Emitter<ChatListState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    add(
      FetchChatUsers(
        page: 1,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        refresh: true,
      ),
    );
  }

  /// Handles starting a chat with a user.
  Future<void> _onStartChat(
    StartChat event,
    Emitter<ChatListState> emit,
  ) async {
    emit(state.copyWith(isStartingChat: true, clearError: true));

    try {
      // 1. Start the chat to get conversation ID
      final startChatResponse = await _chatRepository.startChat(event.userId);
      final conversationId = startChatResponse.conversationId;

      // 2. Mark conversation as read (fire and forget, don't fail if this fails)
      try {
        await _chatRepository.markConversationAsRead(conversationId);
      } catch (e) {
        log('Failed to mark conversation as read: $e');
      }

      emit(
        state.copyWith(
          isStartingChat: false,
          isSuccess: true,
          startedConversationId: conversationId,
          startedUserName: event.userName,
          startedUserProfilePic: event.userProfilePic,
        ),
      );
    } on ApiException catch (e, s) {
      log('StartChat error: $e trace: $s');
      emit(
        state.copyWith(
          isStartingChat: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e, s) {
      log('StartChat error: $e trace: $s');
      emit(
        state.copyWith(
          isStartingChat: false,
          isSuccess: false,
          errorMessage: 'Failed to start chat. Please try again.',
        ),
      );
    }
  }

  /// Clears chat started state after navigation.
  void _onClearChatStarted(
    ClearChatStarted event,
    Emitter<ChatListState> emit,
  ) {
    emit(state.copyWith(clearStartedChat: true));
  }

  /// Clears error message.
  void _onClearError(ClearChatListError event, Emitter<ChatListState> emit) {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
