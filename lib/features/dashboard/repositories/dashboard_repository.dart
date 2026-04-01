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

  /// Fetches today's student timetable.
  Future<TodayTimetableResponse> getStudentTimetable() async {
    try {
      final response = await _apiClient.get(Endpoints.studentTimetables);

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch student timetable',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return TodayTimetableResponse.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('DashboardRepository.getStudentTimetable error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch student timetable: ${e.toString()}',
      );
    }
  }

  /// Fetches today's teacher timetable.
  Future<TodayTimetableResponse> getTeacherTimetable() async {
    try {
      final response = await _apiClient.get(Endpoints.teacherTimetables);

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch teacher timetable',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return TodayTimetableResponse.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('DashboardRepository.getTeacherTimetable error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch teacher timetable: ${e.toString()}',
      );
    }
  }

  // TODO: Uncomment when API is ready
  // /// Fetches today's timetable for dashboard.
  // Future<DashboardTimetable> getTimetable() async {
  //   try {
  //     final response = await _apiClient.get(
  //       Endpoints.dashboardTimetable, // TODO: Add endpoint
  //     );
  //
  //     if (response.statusCode != null &&
  //         (response.statusCode! < 200 || response.statusCode! >= 300)) {
  //       throw ApiException(
  //         message: 'Failed to fetch timetable',
  //         statusCode: response.statusCode,
  //       );
  //     }
  //
  //     if (response.data == null) {
  //       throw const ApiException(message: 'Empty response from server');
  //     }
  //
  //     final responseData = response.data as Map<String, dynamic>;
  //     final data = responseData['data'] as Map<String, dynamic>? ?? {};
  //     return DashboardTimetable.fromJson(data);
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioException(e);
  //   } catch (e, s) {
  //     log('DashboardRepository.getTimetable error: $e trace: $s');
  //     if (e is ApiException) rethrow;
  //     throw ApiException(
  //       message: 'Failed to fetch timetable: ${e.toString()}',
  //     );
  //   }
  // }

  // TODO: Uncomment when API is ready
  // /// Fetches recently paid fees for dashboard.
  // Future<DashboardRecentlyPaid> getRecentlyPaid() async {
  //   try {
  //     final response = await _apiClient.get(
  //       Endpoints.dashboardRecentlyPaid, // TODO: Add endpoint
  //     );
  //
  //     if (response.statusCode != null &&
  //         (response.statusCode! < 200 || response.statusCode! >= 300)) {
  //       throw ApiException(
  //         message: 'Failed to fetch recently paid',
  //         statusCode: response.statusCode,
  //       );
  //     }
  //
  //     if (response.data == null) {
  //       throw const ApiException(message: 'Empty response from server');
  //     }
  //
  //     final responseData = response.data as Map<String, dynamic>;
  //     final data = responseData['data'] as Map<String, dynamic>? ?? {};
  //     return DashboardRecentlyPaid.fromJson(data);
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioException(e);
  //   } catch (e, s) {
  //     log('DashboardRepository.getRecentlyPaid error: $e trace: $s');
  //     if (e is ApiException) rethrow;
  //     throw ApiException(
  //       message: 'Failed to fetch recently paid: ${e.toString()}',
  //     );
  //   }
  // }
}
