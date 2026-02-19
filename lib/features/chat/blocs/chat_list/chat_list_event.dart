import 'package:equatable/equatable.dart';

/// Base class for all chat list events.
sealed class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch chat users list.
class FetchChatUsers extends ChatListEvent {
  const FetchChatUsers({this.page = 1, this.search, this.refresh = false});

  final int page;
  final String? search;
  final bool refresh;

  @override
  List<Object?> get props => [page, search, refresh];
}

/// Event to search chat users.
class SearchChatUsers extends ChatListEvent {
  const SearchChatUsers(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to load more chat users (pagination).
class LoadMoreChatUsers extends ChatListEvent {
  const LoadMoreChatUsers();
}

/// Event to refresh chat users list.
class RefreshChatUsers extends ChatListEvent {
  const RefreshChatUsers();
}

/// Event to start a chat with a user.
class StartChat extends ChatListEvent {
  const StartChat({
    required this.userId,
    required this.userName,
    this.userProfilePic,
  });

  final String userId;
  final String userName;
  final String? userProfilePic;

  @override
  List<Object?> get props => [userId, userName, userProfilePic];
}

/// Event to clear chat started state.
class ClearChatStarted extends ChatListEvent {
  const ClearChatStarted();
}

/// Event to clear error message.
class ClearChatListError extends ChatListEvent {
  const ClearChatListError();
}
