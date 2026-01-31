import 'package:equatable/equatable.dart';

/// Model for login request payload.
class LoginRequest extends Equatable {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  @override
  List<Object?> get props => [email, password];
}

/// Model for login response.
class LoginResponse extends Equatable {
  const LoginResponse({
    required this.success,
    required this.accessToken,
    required this.refreshToken,
  });

  final bool success;
  final String accessToken;
  final String refreshToken;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      success: json['success'] ?? false,
      accessToken: data['access_token'] ?? '',
      refreshToken: data['refresh_token'] ?? '',
    );
  }

  @override
  List<Object?> get props => [success, accessToken, refreshToken];
}
