import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/role_model.dart';

/// Repository for handling role-related API operations.
class RolesRepository {
  RolesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches all available roles.
  ///
  /// [pageSize] - The number of items per page (default: 100 to fetch all).
  ///
  /// Throws [ApiException] if the request fails.
  Future<RolesListResponse> getRoles({int page = 1, int pageSize = 100}) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pagesize': pageSize};

      final response = await _apiClient.get(
        Endpoints.roles,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch roles',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return RolesListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('RolesRepository.getRoles error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch roles: ${e.toString()}');
    }
  }

  /// Fetches all roles as a simple list (convenience method).
  ///
  /// This fetches all pages if necessary to get complete role list.
  Future<List<RoleModel>> getAllRoles() async {
    try {
      final response = await getRoles(pageSize: 100);
      return response.results;
    } catch (e) {
      log('RolesRepository.getAllRoles error: $e');
      rethrow;
    }
  }
}
