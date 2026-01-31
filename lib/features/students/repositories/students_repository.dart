import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
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
  Future<StudentListResponse> getStudents({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'pagesize': pageSize};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.get(
      Endpoints.students,
      queryParameters: queryParams,
    );

    return StudentListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches a single student by ID.
  Future<StudentModel> getStudentById(int id) async {
    final response = await _apiClient.get('${Endpoints.students}$id/');
    return StudentModel.fromJson(response.data as Map<String, dynamic>);
  }
}
