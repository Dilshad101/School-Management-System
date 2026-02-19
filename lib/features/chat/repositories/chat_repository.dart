import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/chat_models.dart';

/// Repository for handling chat-related API operations.
class ChatRepository {
  ChatRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of chat users/contacts.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  /// [search] - Optional search query for filtering users.
  ///
  /// Throws [ApiException] if the request fails.
  Future<ChatUserListResponse> getChatUsers({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pagesize': pageSize};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        Endpoints.chat,
        queryParameters: queryParams,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch chat users',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return ChatUserListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('getChatUsers error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch chat users: ${e.toString()}',
      );
    }
  }

  /// Starts a chat with a user.
  ///
  /// [userId] - The ID of the user to start chat with.
  ///
  /// Returns [StartChatResponse] containing the conversation ID.
  /// Throws [ApiException] if the request fails.
  Future<StartChatResponse> startChat(String userId) async {
    try {
      final response = await _apiClient.post(
        Endpoints.chatStartChat,
        data: {'user_id': userId},
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to start chat',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return StartChatResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('startChat error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to start chat: ${e.toString()}');
    }
  }

  /// Fetches messages for a conversation.
  ///
  /// [conversationId] - The ID of the conversation.
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  ///
  /// Throws [ApiException] if the request fails.
  Future<MessageListResponse> getConversationMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pagesize': pageSize};

      final response = await _apiClient.get(
        Endpoints.chatConversation(conversationId),
        queryParameters: queryParams,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch messages',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return MessageListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('getConversationMessages error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch messages: ${e.toString()}');
    }
  }

  /// Marks all messages in a conversation as read.
  ///
  /// [conversationId] - The ID of the conversation.
  ///
  /// Throws [ApiException] if the request fails.
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final response = await _apiClient.post(
        Endpoints.chatMarkRead(conversationId),
        data: {},
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to mark conversation as read',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('markConversationAsRead error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to mark conversation as read: ${e.toString()}',
      );
    }
  }

  /// Sends a message in a conversation.
  ///
  /// [conversationId] - The ID of the conversation.
  /// [message] - The message text to send.
  ///
  /// Returns the sent message.
  /// Throws [ApiException] if the request fails.
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.chatConversation(conversationId),
        data: {'message': message},
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to send message',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return ChatMessageModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('sendMessage error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to send message: ${e.toString()}');
    }
  }
}
