import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/auth/session.dart';
import 'package:school_management_system/core/storage/local_storage.dart';
import 'package:school_management_system/core/utils/di.dart';
import 'package:school_management_system/features/auth/models/login_model.dart';
import 'package:school_management_system/features/auth/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

/// Bloc for managing authentication state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required SharedPref sharedPref,
  }) : _authRepository = authRepository,
       _sharedPref = sharedPref,
       super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthErrorCleared>(_onAuthErrorCleared);
  }

  final AuthRepository _authRepository;
  final SharedPref _sharedPref;

  /// Handle checking if user is already logged in.
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = _sharedPref.isUserLoggedIn();
    final token = _sharedPref.getToken();

    if (isLoggedIn && token != null && token.isNotEmpty) {
      // Restore session
      locator<SessionHolder>().session = Session(
        accessToken: token,
        userId: '', // Will be populated from user details
        role: UserRole.schoolAdmin,
      );

      emit(
        state.copyWith(status: AuthStatus.authenticated, accessToken: token),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  /// Handle login request.
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );

      final response = await _authRepository.login(request);

      if (response.success) {
        // Save tokens to storage
        await _sharedPref.setToken(response.accessToken);
        await _sharedPref.setUserLoggedIn(true);
        await _sharedPref.setString('refresh_token', response.refreshToken);

        // Update session holder
        locator<SessionHolder>().session = Session(
          accessToken: response.accessToken,
          userId: '', // Will be populated from user details
          role: UserRole.schoolAdmin,
        );

        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage: 'Login failed. Please try again.',
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password.';
      } else if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          errorMessage = data['message'];
        } else {
          errorMessage = 'Invalid credentials.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }

      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: errorMessage),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  /// Handle logout request.
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Clear storage
    await _sharedPref.clear();

    // Clear session
    locator<SessionHolder>().session = null;

    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Handle clearing error messages.
  void _onAuthErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(errorMessage: null));
  }
}
