import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/dashboard_models.dart';

/// Repository for handling dashboard-related API operations.
class DashboardRepository {
  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches total student and employee count.
  Future<StudentEmployeeCount> getStudentEmployeeCount() async {
    try {
      final response = await _apiClient.get(
        Endpoints.dashboardStudentEmployeeCount,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch student/employee count',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return StudentEmployeeCount.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('DashboardRepository.getStudentEmployeeCount error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch student/employee count: ${e.toString()}',
      );
    }
  }

  /// Fetches total pending fees.
  Future<PendingFees> getPendingFees() async {
    try {
      final response = await _apiClient.get(Endpoints.dashboardPendingFees);

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch pending fees',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return PendingFees.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('DashboardRepository.getPendingFees error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch pending fees: ${e.toString()}',
      );
    }
  }

  /// Fetches last six months payment data.
  Future<LastSixMonthsPayments> getLastSixMonthsPayments() async {
    try {
      final response = await _apiClient.get(
        Endpoints.dashboardLastSixMonthsPayments,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch payment data',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as List<dynamic>? ?? [];
      return LastSixMonthsPayments.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('DashboardRepository.getLastSixMonthsPayments error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch payment data: ${e.toString()}',
      );
    }
  }
}
