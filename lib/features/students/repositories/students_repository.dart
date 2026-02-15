import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/academic_year_model.dart';
import '../models/class_room_model.dart';
import '../models/create_student_request.dart';
import '../models/student_model.dart';

/// Repository for handling student-related API operations.
class StudentsRepository {
  StudentsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of students.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  /// [search] - Optional search query for filtering students.
  ///
  /// Throws [ApiException] if the request fails.
  Future<StudentListResponse> getStudents({
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
        Endpoints.students,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch students',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return StudentListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch students: ${e.toString()}');
    }
  }

  /// Fetches a single student by ID.
  ///
  /// Throws [ApiException] if the request fails.
  Future<StudentModel> getStudentById(int id) async {
    try {
      final response = await _apiClient.get('${Endpoints.students}$id/');

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch student details',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return StudentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch student details: ${e.toString()}',
      );
    }
  }

  /// Fetches a list of classrooms for dropdown.
  ///
  /// Throws [ApiException] if the request fails.
  Future<ClassRoomListResponse> getClassRooms({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pagesize': pageSize};

      final response = await _apiClient.get(
        Endpoints.classRooms,
        queryParameters: queryParams,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch classrooms',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return ClassRoomListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch classrooms: ${e.toString()}',
      );
    }
  }

  /// Fetches a list of academic years for dropdown.
  ///
  /// Throws [ApiException] if the request fails.
  Future<AcademicYearListResponse> getAcademicYears({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pagesize': pageSize};

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

  /// Creates a new student.
  ///
  /// Throws [ApiException] if the request fails.
  Future<StudentModel> createStudent(CreateStudentRequest request) async {
    try {
      final payload = await request.toJson();

      final response = await _apiClient.post(Endpoints.students, data: payload);

      if (response.statusCode != 201) {
        throw ApiException(
          message: 'Failed to create student',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return StudentModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to create student: ${e.toString()}');
    }
  }

  /// Updates an existing student.
  ///
  /// Throws [ApiException] if the request fails.
  Future<StudentModel> updateStudent(
    int id,
    UpdateStudentRequest request,
  ) async {
    try {
      final payload = await request.toJson();

      final response = await _apiClient.patch(
        '${Endpoints.students}$id/',
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to update student',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return StudentModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to update student: ${e.toString()}');
    }
  }
}
