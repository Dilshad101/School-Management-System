import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/chat_repository.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

export 'conversation_event.dart';
export 'conversation_state.dart';

/// BLoC for managing a conversation state.
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ConversationState()) {
    on<InitializeConversation>(_onInitializeConversation);
    on<FetchMessages>(_onFetchMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<ClearConversationError>(_onClearError);
  }

  final ChatRepository _chatRepository;

  /// Handles initializing a conversation.
  Future<void> _onInitializeConversation(
    InitializeConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(
      state.copyWith(
        conversationId: event.conversationId,
        userName: event.userName,
        userProfilePic: event.userProfilePic,
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      // Fetch messages
      final response = await _chatRepository.getConversationMessages(
        conversationId: event.conversationId,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          messages: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasNext: response.hasNext,
          hasPrevious: response.hasPrevious,
        ),
      );
    } on ApiException catch (e, s) {
      log('InitializeConversation error: $e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e, s) {
      log('InitializeConversation error: $e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Failed to load messages. Please try again.',
        ),
      );
    }
  }

  /// Handles fetching messages.
  Future<void> _onFetchMessages(
    FetchMessages event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.conversationId == null) return;

    if (!event.refresh) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final response = await _chatRepository.getConversationMessages(
        conversationId: state.conversationId!,
        page: event.page,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          messages: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasNext: response.hasNext,
          hasPrevious: response.hasPrevious,
        ),
      );
    } on ApiException catch (e, s) {
      log('FetchMessages error: $e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e, s) {
      log('FetchMessages error: $e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Failed to fetch messages. Please try again.',
        ),
      );
    }
  }

  /// Handles loading more messages (pagination).
  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.conversationId == null || !state.canLoadMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _chatRepository.getConversationMessages(
        conversationId: state.conversationId!,
        page: nextPage,
      );

      // Prepend older messages to existing list (for chat, older messages come first)
      final updatedMessages = [...response.results, ...state.messages];

      emit(
        state.copyWith(
          isLoadingMore: false,
          messages: updatedMessages,
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
          errorMessage: 'Failed to load more messages.',
        ),
      );
    }
  }

  /// Handles sending a message.
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.conversationId == null) return;
    if (event.message.trim().isEmpty) return;

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      final sentMessage = await _chatRepository.sendMessage(
        conversationId: state.conversationId!,
        message: event.message,
      );

      // Add sent message to the list
      final updatedMessages = [...state.messages, sentMessage];

      emit(
        state.copyWith(
          isSending: false,
          isSuccess: true,
          messages: updatedMessages,
          totalCount: state.totalCount + 1,
        ),
      );
    } on ApiException catch (e, s) {
      log('SendMessage error: $e trace: $s');
      emit(
        state.copyWith(
          isSending: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e, s) {
      log('SendMessage error: $e trace: $s');
      emit(
        state.copyWith(
          isSending: false,
          isSuccess: false,
          errorMessage: 'Failed to send message. Please try again.',
        ),
      );
    }
  }

  /// Handles marking conversation as read.
  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.conversationId == null) return;

    try {
      await _chatRepository.markConversationAsRead(state.conversationId!);
    } catch (e, s) {
      log('MarkAsRead error: $e trace: $s');
      // Don't emit error for mark as read - it's not critical
    }
  }

  /// Clears error message.
  void _onClearError(
    ClearConversationError event,
    Emitter<ConversationState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }
}
