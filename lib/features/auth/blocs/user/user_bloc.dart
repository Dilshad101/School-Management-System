import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/auth/session.dart';
import 'package:school_management_system/core/tenant/tenant_context.dart';
import 'package:school_management_system/core/utils/di.dart';
import 'package:school_management_system/features/auth/repositories/user_repository.dart';

import 'user_event.dart';
import 'user_state.dart';

export 'user_event.dart';
export 'user_state.dart';

/// Bloc for managing user details state.
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const UserState()) {
    on<UserDetailsFetchRequested>(_onUserDetailsFetchRequested);
    on<UserCleared>(_onUserCleared);
    on<UserErrorCleared>(_onUserErrorCleared);
  }

  final UserRepository _userRepository;

  /// Handle fetching user details.
  Future<void> _onUserDetailsFetchRequested(
    UserDetailsFetchRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final user = await _userRepository.getUserDetails();

      // Update session with user ID and school info
      final sessionHolder = locator<SessionHolder>();
      if (sessionHolder.session != null) {
        sessionHolder.session = Session(
          accessToken: sessionHolder.session!.accessToken,
          userId: user.id.toString(),
          role: user.isSuperuser
              ? UserRole.superAdmin
              : user.isPlatformAdmin
              ? UserRole.superAdmin
              : UserRole.schoolAdmin,
          schoolId: user.primarySchoolId,
        );

        // Set tenant context if user has a school
        if (user.primarySchoolId != null) {
          locator<TenantContext>().selectSchool(user.primarySchoolId!);
        }
      }

      emit(state.copyWith(status: UserStatus.success, user: user));
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch user details.';

      if (e.response?.statusCode == 401) {
        errorMessage = 'Session expired. Please login again.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }

      emit(
        state.copyWith(status: UserStatus.failure, errorMessage: errorMessage),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: 'An unexpected error occurred.',
        ),
      );
    }
  }

  /// Handle clearing user data.
  void _onUserCleared(UserCleared event, Emitter<UserState> emit) {
    emit(const UserState());
  }

  /// Handle clearing error messages.
  void _onUserErrorCleared(UserErrorCleared event, Emitter<UserState> emit) {
    emit(state.copyWith(errorMessage: null));
  }
}
