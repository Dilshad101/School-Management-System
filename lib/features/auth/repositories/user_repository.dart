import 'package:school_management_system/core/network/api_client.dart';
import 'package:school_management_system/core/network/endpoints.dart';
import 'package:school_management_system/features/auth/models/user_model.dart';

/// Repository for user-related API calls.
class UserRepository {
  const UserRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches current user details.
  /// Returns [UserModel] on success, throws on failure.
  Future<UserModel> getUserDetails() async {
    try {
      final response = await _apiClient.get(Endpoints.me);

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to fetch user details: Invalid response');
    } catch (e) {
      rethrow;
    }
  }
}
