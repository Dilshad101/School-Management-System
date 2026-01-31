import 'package:equatable/equatable.dart';

/// Enum for authentication status.
enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

/// Immutable state class for AuthBloc.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  /// Helper getters
  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isFailure => status == AuthStatus.failure;

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? refreshToken,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, accessToken, refreshToken, errorMessage];
}
