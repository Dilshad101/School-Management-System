import 'package:dio/dio.dart';

/// Custom exception class for API errors.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? errors;

  /// Creates an ApiException from a DioException.
  factory ApiException.fromDioException(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;

    // Try to extract error message from response
    String message = 'An unexpected error occurred';
    String? errorCode;
    Map<String, dynamic>? errors;

    if (response?.data != null) {
      final data = response!.data;
      if (data is Map<String, dynamic>) {
        // Common error response formats
        message =
            data['message'] as String? ??
            data['error'] as String? ??
            data['detail'] as String? ??
            _getStatusMessage(statusCode);

        errorCode = data['code'] as String? ?? data['error_code'] as String?;

        // Extract field-level errors if present
        if (data['errors'] is Map<String, dynamic>) {
          errors = data['errors'] as Map<String, dynamic>;
        }
      } else if (data is String && data.isNotEmpty) {
        message = data;
      }
    } else {
      message = _getMessageFromType(e.type, statusCode);
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      errors: errors,
    );
  }

  /// Creates an ApiException from generic exception.
  factory ApiException.fromException(Object e) {
    if (e is DioException) {
      return ApiException.fromDioException(e);
    }
    return ApiException(message: e.toString());
  }

  /// Gets a user-friendly message based on HTTP status code.
  static String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 408:
        return 'Request timed out. Please try again.';
      case 409:
        return 'A conflict occurred. Please refresh and try again.';
      case 422:
        return 'Invalid data provided.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  /// Gets a user-friendly message based on DioExceptionType.
  static String _getMessageFromType(DioExceptionType type, int? statusCode) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.badResponse:
        return _getStatusMessage(statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Please check your internet connection.';
      case DioExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Check if this is an authentication error.
  bool get isAuthError => statusCode == 401;

  /// Check if this is a network error.
  bool get isNetworkError =>
      statusCode == null || statusCode == 408 || statusCode == 503;

  /// Check if this is a server error.
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if this is a client error.
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  @override
  String toString() => message;
}
