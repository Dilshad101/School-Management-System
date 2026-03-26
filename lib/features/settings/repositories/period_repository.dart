import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/period_model.dart';

/// Repository for handling period-related API operations.
class PeriodRepository {
  PeriodRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of periods.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  /// [search] - Optional search query for filtering.
  ///
  /// Throws [ApiException] if the request fails.
  Future<PeriodListResponse> getPeriods({
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
        Endpoints.periods,
        queryParameters: queryParams,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch periods',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return PeriodListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch periods: ${e.toString()}');
    }
  }

  /// Creates a new period.
  ///
  /// [startTime] - Start time in "HH:mm" format.
  /// [endTime] - End time in "HH:mm" format.
  /// [order] - The order/sequence number.
  /// [schoolId] - The school ID.
  ///
  /// Throws [ApiException] if the request fails.
  Future<PeriodModel> createPeriod({
    required String startTime,
    required String endTime,
    required int order,
    required String schoolId,
  }) async {
    try {
      final payload = {
        'start_time': startTime,
        'end_time': endTime,
        'order': order.toString(),
        'school': schoolId,
      };

      final response = await _apiClient.post(Endpoints.periods, data: payload);

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create period',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final periodData = data['data'] as Map<String, dynamic>? ?? data;

      return PeriodModel.fromJson(periodData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to create period: ${e.toString()}');
    }
  }

  /// Updates an existing period.
  ///
  /// [id] - The period ID to update.
  /// [startTime] - Start time in "HH:mm" format.
  /// [endTime] - End time in "HH:mm" format.
  /// [order] - The order/sequence number.
  ///
  /// Throws [ApiException] if the request fails.
  Future<PeriodModel> updatePeriod({
    required String id,
    required String startTime,
    required String endTime,
    required int order,
  }) async {
    try {
      final payload = {
        'start_time': startTime,
        'end_time': endTime,
        'order': order,
      };

      final response = await _apiClient.patch(
        '${Endpoints.periods}$id/',
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update period',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final periodData = data['data'] as Map<String, dynamic>? ?? data;

      return PeriodModel.fromJson(periodData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to update period: ${e.toString()}');
    }
  }
}
