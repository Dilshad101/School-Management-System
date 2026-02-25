import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../../students/models/class_room_model.dart';
import '../../students/models/student_model.dart';
import '../models/create_notification_request.dart';
import '../models/notification_models.dart';

/// Repository for handling notification-related API operations.
class NotificationRepository {
  NotificationRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of notifications.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  ///
  /// Throws [ApiException] if the request fails.
  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pagesize': pageSize};

      final response = await _apiClient.get(
        Endpoints.notifications,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch notifications',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return NotificationListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('NotificationRepository.getNotifications error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch notifications: ${e.toString()}',
      );
    }
  }

  /// Creates a new notification.
  ///
  /// Throws [ApiException] if the request fails.
  Future<NotificationModel> createNotification(
    CreateNotificationRequest request,
  ) async {
    try {
      final payload = await request.toJson();

      final response = await _apiClient.post(
        Endpoints.notifications,
        data: payload,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create notification',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return NotificationModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('NotificationRepository.createNotification error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create notification: ${e.toString()}',
      );
    }
  }

  /// Searches for classrooms with optional search query.
  ///
  /// Throws [ApiException] if the request fails.
  Future<ClassRoomListResponse> searchClassrooms({
    String? search,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'pagesize': pageSize};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        Endpoints.classRooms,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch classrooms',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return ClassRoomListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('NotificationRepository.searchClassrooms error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch classrooms: ${e.toString()}',
      );
    }
  }

  /// Searches for students with optional search query.
  ///
  /// Throws [ApiException] if the request fails.
  Future<StudentListResponse> searchStudents({
    String? search,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'pagesize': pageSize};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        Endpoints.students,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch students',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return StudentListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('NotificationRepository.searchStudents error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch students: ${e.toString()}');
    }
  }
}
