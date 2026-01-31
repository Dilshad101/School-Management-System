import 'package:school_management_system/core/network/api_client.dart';
import 'package:school_management_system/core/network/endpoints.dart';
import 'package:school_management_system/features/auth/models/login_model.dart';

/// Repository for authentication-related API calls.
class AuthRepository {
  const AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Performs login with email and password.
  /// Returns [LoginResponse] on success, throws on failure.
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        Endpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return LoginResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Login failed: Invalid response');
    } catch (e) {
      rethrow;
    }
  }
}
