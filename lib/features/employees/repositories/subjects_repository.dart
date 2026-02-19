import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/subject_model.dart';

/// Repository for handling subject-related API operations.
class SubjectsRepository {
  SubjectsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches subjects with pagination and optional search.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  /// [search] - Optional search query for filtering subjects.
  ///
  /// Throws [ApiException] if the request fails.
  Future<SubjectsListResponse> getSubjects({
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
        Endpoints.subjects,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch subjects',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return SubjectsListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('SubjectsRepository.getSubjects error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch subjects: ${e.toString()}');
    }
  }

  /// Fetches all subjects (convenience method for getting complete list).
  ///
  /// This fetches all pages if necessary.
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final response = await getSubjects(pageSize: 100);
      return response.results;
    } catch (e) {
      log('SubjectsRepository.getAllSubjects error: $e');
      rethrow;
    }
  }
}
