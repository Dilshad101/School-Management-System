import 'package:equatable/equatable.dart';
import 'package:school_management_system/features/auth/models/user_model.dart';

/// Enum for user details fetch status.
enum UserStatus { initial, loading, success, failure }

/// Immutable state class for UserBloc.
class UserState extends Equatable {
  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
  });

  final UserStatus status;
  final UserModel? user;
  final String? errorMessage;

  /// Helper getters
  bool get isLoading => status == UserStatus.loading;
  bool get isSuccess => status == UserStatus.success;
  bool get isFailure => status == UserStatus.failure;
  bool get hasUser => user != null;

  UserState copyWith({
    UserStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
