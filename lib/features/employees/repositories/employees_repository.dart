import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/employee_model.dart';

/// Repository for handling employee-related API operations.
class EmployeesRepository {
  EmployeesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of employees (school users).
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  /// [search] - Optional search query for filtering employees.
  ///
  /// Throws [ApiException] if the request fails.
  Future<EmployeeListResponse> getEmployees({
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
        Endpoints.schoolUsers,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch employees',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return EmployeeListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('$e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch employees: ${e.toString()}');
    }
  }

  /// Fetches a single employee by ID.
  ///
  /// Throws [ApiException] if the request fails.
  Future<EmployeeModel> getEmployeeById(String id) async {
    try {
      final response = await _apiClient.get('${Endpoints.schoolUsers}$id/');

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch employee details',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return EmployeeModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch employee details: ${e.toString()}',
      );
    }
  }

  /// Fetches a single employee by ID and returns raw JSON data.
  ///
  /// This is useful for pre-filling edit forms.
  /// Throws [ApiException] if the request fails.
  Future<Map<String, dynamic>> getEmployeeDetailsById(String id) async {
    try {
      final response = await _apiClient.get('${Endpoints.schoolUsers}$id/');

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch employee details',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      return responseData['data'] as Map<String, dynamic>? ?? responseData;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch employee details: ${e.toString()}',
      );
    }
  }

  /// Deletes an employee by ID.
  ///
  /// Throws [ApiException] if the request fails.
  Future<void> deleteEmployee(String id) async {
    try {
      final response = await _apiClient.delete('${Endpoints.schoolUsers}$id/');

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to delete employee',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to delete employee: ${e.toString()}');
    }
  }

  /// Creates a new employee.
  ///
  /// [payload] - The request payload containing employee data.
  ///
  /// Returns the created [EmployeeModel].
  /// Throws [ApiException] if the request fails.
  Future<EmployeeModel> createEmployee(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        Endpoints.schoolUsers,
        data: payload,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create employee',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return EmployeeModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('EmployeesRepository.createEmployee error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to create employee: ${e.toString()}');
    }
  }

  /// Updates an existing employee.
  ///
  /// [id] - The employee ID to update.
  /// [payload] - The request payload containing updated employee data.
  ///
  /// Returns the updated [EmployeeModel].
  /// Throws [ApiException] if the request fails.
  Future<EmployeeModel> updateEmployee(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${Endpoints.schoolUsers}$id/',
        data: payload,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update employee',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return EmployeeModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('EmployeesRepository.updateEmployee error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to update employee: ${e.toString()}');
    }
  }
}
