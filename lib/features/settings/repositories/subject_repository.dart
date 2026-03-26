import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/subject_model.dart';

/// Repository for handling subject CRUD operations in settings.
class SubjectRepository {
  SubjectRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of subjects.
  Future<SubjectListResponse> getSubjects({
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

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch subjects',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return SubjectListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch subjects: ${e.toString()}');
    }
  }

  /// Creates a new subject.
  Future<SubjectModel> createSubject({
    required String name,
    required String code,
    required bool isLab,
    required String schoolId,
  }) async {
    try {
      final payload = {
        'name': name,
        'code': code,
        'is_lab': isLab,
        'school': schoolId,
      };

      final response = await _apiClient.post(Endpoints.subjects, data: payload);

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create subject',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final subjectData = data['data'] as Map<String, dynamic>? ?? data;

      return SubjectModel.fromJson(subjectData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to create subject: ${e.toString()}');
    }
  }

  /// Updates an existing subject.
  Future<SubjectModel> updateSubject({
    required String id,
    required String name,
    required String code,
    required bool isLab,
  }) async {
    try {
      final payload = {'name': name, 'code': code, 'is_lab': isLab};

      final response = await _apiClient.patch(
        '${Endpoints.subjects}$id/',
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update subject',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final subjectData = data['data'] as Map<String, dynamic>? ?? data;

      return SubjectModel.fromJson(subjectData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to update subject: ${e.toString()}');
    }
  }

  /// Deletes a subject.
  Future<void> deleteSubject({required String id}) async {
    try {
      final response = await _apiClient.delete('${Endpoints.subjects}$id/');

      if (response.statusCode != null &&
          response.statusCode != 204 &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to delete subject',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to delete subject: ${e.toString()}');
    }
  }
}
