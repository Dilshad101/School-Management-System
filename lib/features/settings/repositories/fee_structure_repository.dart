import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/fee_structure_model.dart';

/// Repository for handling fee structure CRUD operations.
class FeeStructureRepository {
  FeeStructureRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of fee structures.
  Future<FeeStructureListResponse> getFeeStructures({
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
        Endpoints.feeStructures,
        queryParameters: queryParams,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch fee structures',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return FeeStructureListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch fee structures: ${e.toString()}',
      );
    }
  }

  /// Creates a new fee structure.
  Future<FeeStructureModel> createFeeStructure({
    required String name,
    required String classroomId,
    required String academicYearId,
    required List<Map<String, dynamic>> items,
    required String schoolId,
  }) async {
    try {
      final payload = {
        'name': name,
        'classroom': classroomId,
        'academic_year': academicYearId,
        'items': items,
        'school': schoolId,
      };

      final response = await _apiClient.post(
        Endpoints.feeStructures,
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create fee structure',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final feeStructureData = data['data'] as Map<String, dynamic>? ?? data;

      return FeeStructureModel.fromJson(feeStructureData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create fee structure: ${e.toString()}',
      );
    }
  }

  /// Updates an existing fee structure.
  Future<FeeStructureModel> updateFeeStructure({
    required String id,
    required String name,
    required String classroomId,
    required String academicYearId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final payload = {
        'name': name,
        'classroom': classroomId,
        'academic_year': academicYearId,
        'items': items,
      };

      final response = await _apiClient.patch(
        '${Endpoints.feeStructures}$id/',
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update fee structure',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final feeStructureData = data['data'] as Map<String, dynamic>? ?? data;

      return FeeStructureModel.fromJson(feeStructureData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to update fee structure: ${e.toString()}',
      );
    }
  }

  /// Deletes a fee structure.
  Future<void> deleteFeeStructure({required String id}) async {
    try {
      final response = await _apiClient.delete(
        '${Endpoints.feeStructures}$id/',
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to delete fee structure',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to delete fee structure: ${e.toString()}',
      );
    }
  }
}
