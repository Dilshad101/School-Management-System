import 'package:equatable/equatable.dart';

/// Base class for user events.
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch user details.
class UserDetailsFetchRequested extends UserEvent {
  const UserDetailsFetchRequested();
}

/// Event to clear user data (on logout).
class UserCleared extends UserEvent {
  const UserCleared();
}

/// Event to clear any error messages.
class UserErrorCleared extends UserEvent {
  const UserErrorCleared();
}
