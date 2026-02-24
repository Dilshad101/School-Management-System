import 'package:equatable/equatable.dart';

/// Model for a chat user/contact.
class ChatUserModel extends Equatable {
  const ChatUserModel({
    required this.id,
    required this.firstName,
    this.lastName,
    this.profilePic,
    this.lastMessageText,
    this.lastMessageTime,
    this.conversationId,
    this.unreadCount = 0,
  });

  final String id;
  final String firstName;
  final String? lastName;
  final String? profilePic;
  final String? lastMessageText;
  final DateTime? lastMessageTime;
  final String? conversationId;
  final int unreadCount;

  /// Get the user's full name.
  String get fullName {
    final last = lastName ?? '';
    return '$firstName $last'.trim();
  }

  /// Check if user has unread messages.
  bool get hasUnreadMessages => unreadCount > 0;

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name'],
      profilePic: json['profile_pic'],
      lastMessageText: json['last_message_text'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.tryParse(json['last_message_time'])
          : null,
      conversationId: json['conversation_id'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'profile_pic': profilePic,
      'last_message_text': lastMessageText,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'conversation_id': conversationId,
      'unread_count': unreadCount,
    };
  }

  ChatUserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? profilePic,
    String? lastMessageText,
    DateTime? lastMessageTime,
    String? conversationId,
    int? unreadCount,
  }) {
    return ChatUserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePic: profilePic ?? this.profilePic,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      conversationId: conversationId ?? this.conversationId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    profilePic,
    lastMessageText,
    lastMessageTime,
    conversationId,
    unreadCount,
  ];
}

/// Model for paginated chat users response.
class ChatUserListResponse extends Equatable {
  const ChatUserListResponse({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.results,
  });

  final int count;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final List<ChatUserModel> results;

  factory ChatUserListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return ChatUserListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => ChatUserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    count,
    page,
    pageSize,
    totalPages,
    hasNext,
    hasPrevious,
    results,
  ];
}

/// Model for start chat response.
class StartChatResponse extends Equatable {
  const StartChatResponse({required this.conversationId, required this.isNew});

  final String conversationId;
  final bool isNew;

  factory StartChatResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return StartChatResponse(
      conversationId: data['conversation_id']?.toString() ?? '',
      isNew: data['is_new'] ?? false,
    );
  }

  @override
  List<Object?> get props => [conversationId, isNew];
}

/// Model for a chat message.
class ChatMessageModel extends Equatable {
  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.senderName,
    this.senderProfilePic,
    this.isRead = false,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? senderName;
  final String? senderProfilePic;
  final bool isRead;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Handle sender as either a string ID or an object
    String senderId = '';
    String? senderName;
    String? senderProfilePic;

    if (json['sender'] is Map<String, dynamic>) {
      final senderMap = json['sender'] as Map<String, dynamic>;
      senderId = senderMap['id']?.toString() ?? '';
      final firstName = senderMap['first_name']?.toString() ?? '';
      final lastName = senderMap['last_name']?.toString() ?? '';
      senderName = '$firstName $lastName'.trim();
      senderProfilePic = senderMap['profile_pic'];
    } else {
      senderId =
          json['sender_id']?.toString() ?? json['sender']?.toString() ?? '';
      senderName = json['sender_name'];
      senderProfilePic = json['sender_profile_pic'];
    }

    return ChatMessageModel(
      id: json['id']?.toString() ?? json['message_id']?.toString() ?? '',
      senderId: senderId,
      text:
          json['content']?.toString() ??
          json['text']?.toString() ??
          json['message']?.toString() ??
          '',
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      senderName: senderName,
      senderProfilePic: senderProfilePic,
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'sender_name': senderName,
      'sender_profile_pic': senderProfilePic,
      'is_read': isRead,
    };
  }

  @override
  List<Object?> get props => [
    id,
    senderId,
    text,
    timestamp,
    senderName,
    senderProfilePic,
    isRead,
  ];
}

/// Model for paginated messages response.
class MessageListResponse extends Equatable {
  const MessageListResponse({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.results,
  });

  final int count;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final List<ChatMessageModel> results;

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MessageListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    count,
    page,
    pageSize,
    totalPages,
    hasNext,
    hasPrevious,
    results,
  ];
}
