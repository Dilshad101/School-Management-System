import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/guardian_model.dart';
import '../models/create_guardian_request.dart';

/// Repository for handling guardian-related API operations.
class GuardiansRepository {
  GuardiansRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of guardians.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  /// [search] - Optional search query for filtering guardians.
  /// [classId] - Optional class filter.
  /// [divisionId] - Optional division filter.
  ///
  /// Throws [ApiException] if the request fails.
  Future<GuardianListResponse> getGuardians({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? classId,
    String? divisionId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pagesize': pageSize};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (classId != null && classId.isNotEmpty) {
        queryParams['class_id'] = classId;
      }
      if (divisionId != null && divisionId.isNotEmpty) {
        queryParams['division_id'] = divisionId;
      }

      final response = await _apiClient.get(
        Endpoints.guardians,
        queryParameters: queryParams,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch guardians',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return GuardianListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch guardians: ${e.toString()}');
    }
  }

  /// Fetches a single guardian by ID.
  ///
  /// Throws [ApiException] if the request fails.
  Future<GuardianModel> getGuardianById(String id) async {
    try {
      final response = await _apiClient.get('${Endpoints.guardians}$id/');

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch guardian details',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      // Handle nested data structure: { "success": true, "data": { ... } }
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      return GuardianModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch guardian details: ${e.toString()}',
      );
    }
  }

  /// Looks up a guardian by email.
  ///
  /// Returns existing guardian data if found.
  /// Throws [ApiException] if the request fails.
  Future<GuardianLookupResponse> lookupGuardianByEmail(String email) async {
    try {
      final response = await _apiClient.get(
        '${Endpoints.guardians}lookup/',
        queryParameters: {'email': email},
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to lookup guardian',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        return const GuardianLookupResponse(found: false);
      }

      return GuardianLookupResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to lookup guardian: ${e.toString()}');
    }
  }

  /// Creates a new guardian.
  ///
  /// Throws [ApiException] if the request fails.
  Future<GuardianModel> createGuardian(CreateGuardianRequest request) async {
    try {
      final response = await _apiClient.post(
        Endpoints.guardians,
        data: request.toJson(),
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create guardian',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      // Handle nested data structure: { "success": true, "data": { ... } }
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      return GuardianModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to create guardian: ${e.toString()}');
    }
  }

  /// Updates an existing guardian using PATCH.
  ///
  /// Throws [ApiException] if the request fails.
  Future<GuardianModel> updateGuardian(
    String id,
    UpdateGuardianRequest request,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${Endpoints.guardians}$id/',
        data: request.toJson(),
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update guardian',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      // Handle nested data structure: { "success": true, "data": { ... } }
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      return GuardianModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to update guardian: ${e.toString()}');
    }
  }

  /// Deletes a guardian.
  ///
  /// Throws [ApiException] if the request fails.
  Future<void> deleteGuardian(String id) async {
    try {
      final response = await _apiClient.delete('${Endpoints.guardians}$id/');

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to delete guardian',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to delete guardian: ${e.toString()}');
    }
  }

  /// Searches for students to link with guardian.
  ///
  /// [query] - Search query for student name or ID.
  ///
  /// Throws [ApiException] if the request fails.
  Future<List<LinkedStudentModel>> searchStudentsForLinking(
    String query,
  ) async {
    try {
      final response = await _apiClient.get(
        Endpoints.students,
        queryParameters: {'search': query, 'page': 1},
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to search students',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        return [];
      }

      final responseData = response.data as Map<String, dynamic>;
      // Handle nested data structure: { "success": true, "data": { ... } }
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      final results = data['results'] as List<dynamic>? ?? [];

      return results.map((e) {
        return LinkedStudentModel.fromJson(e as Map<String, dynamic>);
      }).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to search students: ${e.toString()}');
    }
  }
}
