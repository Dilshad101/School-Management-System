import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/academic_year_model.dart';
import '../models/classroom_model.dart';
import '../models/school_user_model.dart';

/// Repository for handling classroom-related API operations.
class ClassroomRepository {
  ClassroomRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of classrooms.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  /// [search] - Optional search query for filtering classrooms.
  ///
  /// Throws [ApiException] if the request fails.
  Future<ClassroomListResponse> getClassrooms({
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
        Endpoints.classRooms,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch classrooms',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return ClassroomListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('$e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch classrooms: ${e.toString()}',
      );
    }
  }

  /// Fetches a single classroom by ID.
  ///
  /// Throws [ApiException] if the request fails.
  Future<ClassroomModel> getClassroomById(String id) async {
    try {
      log('Fetching classroom details for ID: $id');
      final response = await _apiClient.get('${Endpoints.classRooms}$id/');

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch classroom details',
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
      return ClassroomModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch classroom details: ${e.toString()}',
      );
    }
  }

  /// Deletes a classroom by ID.
  ///
  /// Throws [ApiException] if the request fails.
  Future<void> deleteClassroom(String id) async {
    try {
      final response = await _apiClient.delete('${Endpoints.classRooms}$id/');

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to delete classroom',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to delete classroom: ${e.toString()}',
      );
    }
  }

  /// Creates a new classroom.
  ///
  /// Throws [ApiException] if the request fails.
  Future<ClassroomModel> createClassroom({
    required String name,
    required String academicYear,
    required String classTeacher,
    required String school,
    String? roomNumber,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'academic_year': academicYear,
        'class_teacher': classTeacher,
        'school': school,
      };

      if (roomNumber != null && roomNumber.isNotEmpty) {
        payload['room_number'] = roomNumber;
      }

      final response = await _apiClient.post(
        Endpoints.classRooms,
        data: payload,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create classroom',
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
      return ClassroomModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('ClassroomRepository.createClassroom error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create classroom: ${e.toString()}',
      );
    }
  }

  /// Updates an existing classroom.
  ///
  /// Only sends changed fields in the payload.
  /// Throws [ApiException] if the request fails.
  Future<ClassroomModel> updateClassroom({
    required String id,
    String? name,
    String? academicYear,
    String? classTeacher,
    String? roomNumber,
  }) async {
    try {
      final payload = <String, dynamic>{};

      if (name != null) payload['name'] = name;
      if (academicYear != null) payload['academic_year'] = academicYear;
      if (classTeacher != null) payload['class_teacher'] = classTeacher;
      if (roomNumber != null) payload['room_number'] = roomNumber;

      final response = await _apiClient.patch(
        '${Endpoints.classRooms}$id/',
        data: payload,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update classroom',
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
      return ClassroomModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('ClassroomRepository.updateClassroom error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to update classroom: ${e.toString()}',
      );
    }
  }

  /// Fetches academic years with optional search query.
  ///
  /// Throws [ApiException] if the request fails.
  Future<AcademicYearListResponse> getAcademicYears({
    String? search,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'pagesize': pageSize};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        Endpoints.academicYears,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch academic years',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return AcademicYearListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('ClassroomRepository.getAcademicYears error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch academic years: ${e.toString()}',
      );
    }
  }

  /// Fetches school users (teachers) with optional search query.
  ///
  /// Throws [ApiException] if the request fails.
  Future<SchoolUserListResponse> getSchoolUsers({
    String? search,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'pagesize': pageSize};

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
          message: 'Failed to fetch school users',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return SchoolUserListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('ClassroomRepository.getSchoolUsers error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch school users: ${e.toString()}',
      );
    }
  }
}
