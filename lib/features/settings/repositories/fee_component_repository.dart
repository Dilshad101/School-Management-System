import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/fee_component_model.dart';

/// Repository for handling fee component CRUD operations.
class FeeComponentRepository {
  FeeComponentRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of fee components.
  Future<FeeComponentListResponse> getFeeComponents({
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
        Endpoints.feeComponents,
        queryParameters: queryParams,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch fee components',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return FeeComponentListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch fee components: ${e.toString()}',
      );
    }
  }

  /// Creates a new fee component.
  Future<FeeComponentModel> createFeeComponent({
    required String name,
    required String frequency,
    required bool isOptional,
    required String schoolId,
  }) async {
    try {
      final payload = {
        'name': name,
        'frequency': frequency,
        'is_optional': isOptional,
        'school': schoolId,
      };

      final response = await _apiClient.post(
        Endpoints.feeComponents,
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create fee component',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final feeComponentData = data['data'] as Map<String, dynamic>? ?? data;

      return FeeComponentModel.fromJson(feeComponentData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create fee component: ${e.toString()}',
      );
    }
  }

  /// Updates an existing fee component.
  Future<FeeComponentModel> updateFeeComponent({
    required String id,
    required String name,
    required String frequency,
    required bool isOptional,
  }) async {
    try {
      final payload = {
        'name': name,
        'frequency': frequency,
        'is_optional': isOptional,
      };

      final response = await _apiClient.patch(
        '${Endpoints.feeComponents}$id/',
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update fee component',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final feeComponentData = data['data'] as Map<String, dynamic>? ?? data;

      return FeeComponentModel.fromJson(feeComponentData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to update fee component: ${e.toString()}',
      );
    }
  }

  /// Deletes a fee component.
  Future<void> deleteFeeComponent({required String id}) async {
    try {
      final response = await _apiClient.delete(
        '${Endpoints.feeComponents}$id/',
      );

      if (response.statusCode != null &&
          response.statusCode != 204 &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to delete fee component',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to delete fee component: ${e.toString()}',
      );
    }
  }
}
