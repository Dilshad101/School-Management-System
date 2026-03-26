import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/academic_year_model.dart';
import '../models/classroom_model.dart';
import '../models/school_user_model.dart';
import '../models/timetable_model.dart';

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

  /// Fetches the timetable for a classroom.
  ///
  /// [classroomId] - The ID of the classroom.
  /// [academicYearId] - The ID of the academic year.
  ///
  /// Throws [ApiException] if the request fails.
  Future<TimetableResponse> getClassroomTimetable({
    required String classroomId,
    required String academicYearId,
  }) async {
    try {
      // Fetch both periods and timetable data in parallel
      final results = await Future.wait([
        _apiClient.get(Endpoints.periods),
        _apiClient.get(
          Endpoints.timetables,
          queryParameters: {
            'classroom': classroomId,
            'academic_year': academicYearId,
          },
        ),
      ]);

      final periodsResponse = results[0];
      final timetableResponse = results[1];

      if (periodsResponse.statusCode != null &&
          (periodsResponse.statusCode! < 200 ||
              periodsResponse.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch periods',
          statusCode: periodsResponse.statusCode,
        );
      }

      if (timetableResponse.statusCode != null &&
          (timetableResponse.statusCode! < 200 ||
              timetableResponse.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch timetable',
          statusCode: timetableResponse.statusCode,
        );
      }

      if (periodsResponse.data == null || timetableResponse.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return TimetableResponse.fromJsonWithPeriods(
        timetableJson: timetableResponse.data as Map<String, dynamic>,
        periodsJson: periodsResponse.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('ClassroomRepository.getClassroomTimetable error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to fetch timetable: ${e.toString()}');
    }
  }

  /// Creates or updates timetable entries in bulk.
  ///
  /// [schoolId] - The school ID.
  /// [academicYearId] - The academic year ID.
  /// [classroomId] - The classroom ID.
  /// [entries] - List of timetable entries to save.
  ///
  /// Throws [ApiException] if the request fails.
  Future<int> saveTimetableEntries({
    required String schoolId,
    required String academicYearId,
    required String classroomId,
    required List<TimetableEntryPayload> entries,
  }) async {
    try {
      final payload = {
        'school': schoolId,
        'academic_year': academicYearId,
        'classroom': classroomId,
        'timetable': entries.map((e) => e.toJson()).toList(),
      };

      final response = await _apiClient.post(
        Endpoints.timetables,
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to save timetable entries',
          statusCode: response.statusCode,
        );
      }

      // Parse the response to get entries_created count
      final responseData = response.data as Map<String, dynamic>?;
      final data = responseData?['data'] as Map<String, dynamic>?;
      return data?['entries_created'] as int? ?? entries.length;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      log('ClassroomRepository.saveTimetableEntries error: $e trace: $s');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to save timetable entries: ${e.toString()}',
      );
    }
  }
}

/// Payload model for creating timetable entries.
class TimetableEntryPayload {
  const TimetableEntryPayload({
    required this.dayOfWeek,
    required this.periodId,
    required this.teacherId,
    required this.subjectId,
  });

  final int dayOfWeek;
  final String periodId;
  final String teacherId;
  final String subjectId;

  Map<String, dynamic> toJson() => {
    'day_of_week': dayOfWeek,
    'period': periodId,
    'teacher': teacherId,
    'subject': subjectId,
  };
}
