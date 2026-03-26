import 'package:equatable/equatable.dart';

/// Base class for all fees events.
abstract class FeesEvent extends Equatable {
  const FeesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch fees list.
class FeesFetchRequested extends FeesEvent {
  const FeesFetchRequested({this.page = 1, this.search, this.refresh = false});

  final int page;
  final String? search;
  final bool refresh;

  @override
  List<Object?> get props => [page, search, refresh];
}

/// Event to load more fees (pagination).
class FeesLoadMoreRequested extends FeesEvent {
  const FeesLoadMoreRequested();
}

/// Event to search fees.
class FeesSearchRequested extends FeesEvent {
  const FeesSearchRequested({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to clear search and reset to initial state.
class FeesSearchCleared extends FeesEvent {
  const FeesSearchCleared();
}

/// Event to clear any error.
class FeesErrorCleared extends FeesEvent {
  const FeesErrorCleared();
}
