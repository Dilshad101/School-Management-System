import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/student_fee_assignment_model.dart';
import '../models/student_fee_model.dart';

/// Repository for handling fee-related API operations.
class FeesRepository {
  FeesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetches a paginated list of student fees.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page (default: 10).
  /// [search] - Optional search query for filtering fees.
  ///
  /// Throws [ApiException] if the request fails.
  Future<StudentFeeListResponse> getStudentFees({
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
        Endpoints.studentFees,
        queryParameters: queryParams,
      );

      // Validate status code
      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to fetch student fees',
          statusCode: response.statusCode,
        );
      }

      // Validate response data
      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      return StudentFeeListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch student fees: ${e.toString()}',
      );
    }
  }

  /// Creates a new student fee assignment.
  Future<StudentFeeAssignmentModel> createStudentFee({
    required String studentId,
    required String academicYearId,
    required String feeStructureId,
    required String schoolId,
    double totalAmount = 0,
  }) async {
    try {
      final payload = {
        'student': studentId,
        'academic_year': academicYearId,
        'fee_structure': feeStructureId,
        'total_amount': totalAmount,
        'school': schoolId,
      };

      final response = await _apiClient.post(
        Endpoints.studentFeesCreate,
        data: payload,
      );

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw ApiException(
          message: 'Failed to create student fee',
          statusCode: response.statusCode,
        );
      }

      if (response.data == null) {
        throw const ApiException(message: 'Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final feeData = data['data'] as Map<String, dynamic>? ?? data;

      return StudentFeeAssignmentModel.fromJson(feeData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to create student fee: ${e.toString()}',
      );
    }
  }
}
