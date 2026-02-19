import 'package:equatable/equatable.dart';

/// Base class for all conversation events.
sealed class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize a conversation and fetch messages.
class InitializeConversation extends ConversationEvent {
  const InitializeConversation({
    required this.conversationId,
    required this.userName,
    this.userProfilePic,
  });

  final String conversationId;
  final String userName;
  final String? userProfilePic;

  @override
  List<Object?> get props => [conversationId, userName, userProfilePic];
}

/// Event to fetch messages for a conversation.
class FetchMessages extends ConversationEvent {
  const FetchMessages({this.page = 1, this.refresh = false});

  final int page;
  final bool refresh;

  @override
  List<Object?> get props => [page, refresh];
}

/// Event to load more messages (pagination).
class LoadMoreMessages extends ConversationEvent {
  const LoadMoreMessages();
}

/// Event to send a message.
class SendMessage extends ConversationEvent {
  const SendMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Event to mark conversation as read.
class MarkAsRead extends ConversationEvent {
  const MarkAsRead();
}

/// Event to clear error message.
class ClearConversationError extends ConversationEvent {
  const ClearConversationError();
}
