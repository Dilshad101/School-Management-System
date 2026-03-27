import 'package:equatable/equatable.dart';

/// Base class for all dashboard events.
sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all dashboard data.
class DashboardFetchRequested extends DashboardEvent {
  const DashboardFetchRequested();
}

/// Event to refresh dashboard data.
class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

/// Event to clear error.
class DashboardErrorCleared extends DashboardEvent {
  const DashboardErrorCleared();
}
