import 'package:equatable/equatable.dart';

/// Base class for all dashboard events.
sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all dashboard data.
class DashboardFetchRequested extends DashboardEvent {
  const DashboardFetchRequested({this.permissions = const []});

  /// List of permissions the current user has.
  /// Used to conditionally fetch data based on permissions.
  final List<String> permissions;

  @override
  List<Object?> get props => [permissions];
}

/// Event to refresh dashboard data.
class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested({this.permissions = const []});

  /// List of permissions the current user has.
  final List<String> permissions;

  @override
  List<Object?> get props => [permissions];
}

/// Event to clear error.
class DashboardErrorCleared extends DashboardEvent {
  const DashboardErrorCleared();
}
