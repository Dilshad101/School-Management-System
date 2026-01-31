import 'package:equatable/equatable.dart';

/// Base class for auth events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if user is already logged in.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event to login with email and password.
class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Event to logout the user.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Event to clear any error messages.
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
