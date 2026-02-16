import 'package:equatable/equatable.dart';

/// Base class for all guardian events.
abstract class GuardiansEvent extends Equatable {
  const GuardiansEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch guardians list.
class GuardiansFetchRequested extends GuardiansEvent {
  const GuardiansFetchRequested({
    this.page = 1,
    this.search,
    this.classId,
    this.divisionId,
    this.refresh = false,
  });

  final int page;
  final String? search;
  final String? classId;
  final String? divisionId;
  final bool refresh;

  @override
  List<Object?> get props => [page, search, classId, divisionId, refresh];
}

/// Event to load more guardians (pagination).
class GuardiansLoadMoreRequested extends GuardiansEvent {
  const GuardiansLoadMoreRequested();
}

/// Event to search guardians.
class GuardiansSearchRequested extends GuardiansEvent {
  const GuardiansSearchRequested({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to filter guardians by class.
class GuardiansClassFilterChanged extends GuardiansEvent {
  const GuardiansClassFilterChanged({this.classId});

  final String? classId;

  @override
  List<Object?> get props => [classId];
}

/// Event to filter guardians by division.
class GuardiansDivisionFilterChanged extends GuardiansEvent {
  const GuardiansDivisionFilterChanged({this.divisionId});

  final String? divisionId;

  @override
  List<Object?> get props => [divisionId];
}

/// Event to clear all filters.
class GuardiansFiltersCleared extends GuardiansEvent {
  const GuardiansFiltersCleared();
}

/// Event to clear search and reset to initial state.
class GuardiansSearchCleared extends GuardiansEvent {
  const GuardiansSearchCleared();
}

/// Event to clear any error.
class GuardiansErrorCleared extends GuardiansEvent {
  const GuardiansErrorCleared();
}

/// Event to delete a guardian.
class GuardianDeleteRequested extends GuardiansEvent {
  const GuardianDeleteRequested({required this.guardianId});

  final String guardianId;

  @override
  List<Object?> get props => [guardianId];
}

/// Event when a guardian is successfully added (to refresh list).
class GuardianAddedSuccessfully extends GuardiansEvent {
  const GuardianAddedSuccessfully();
}
