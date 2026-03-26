import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/academic_year_model.dart';

/// Repository for handling academic year CRUD operations.
class AcademicYearRepository {
  AcademicYearRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of academic years.
  Future<AcademicYearListResponse> getAcademicYears({
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
        Endpoints.academicYears,
        queryParameters: queryParams,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch academic years',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return AcademicYearListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch academic years: ${e.toString()}',
      );
    }
  }

  /// Creates a new academic year.
  Future<AcademicYearModel> createAcademicYear({
    required String name,
    required String startDate,
    required String endDate,
    required String schoolId,
  }) async {
    try {
      final payload = {
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
        'school': schoolId,
      };

      final response = await _apiClient.post(
        Endpoints.academicYears,
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create academic year',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final academicYearData = data['data'] as Map<String, dynamic>? ?? data;

      return AcademicYearModel.fromJson(academicYearData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create academic year: ${e.toString()}',
      );
    }
  }

  /// Updates an existing academic year.
  Future<AcademicYearModel> updateAcademicYear({
    required String id,
    required String name,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final payload = {
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
      };

      final response = await _apiClient.patch(
        '${Endpoints.academicYears}$id/',
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update academic year',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final academicYearData = data['data'] as Map<String, dynamic>? ?? data;

      return AcademicYearModel.fromJson(academicYearData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to update academic year: ${e.toString()}',
      );
    }
  }

  /// Deletes an academic year.
  Future<void> deleteAcademicYear({required String id}) async {
    try {
      final response = await _apiClient.delete(
        '${Endpoints.academicYears}$id/',
      );

      if (response.statusCode != null &&
          response.statusCode != 204 &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to delete academic year',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to delete academic year: ${e.toString()}',
      );
    }
  }
}
