import 'package:equatable/equatable.dart';

/// Base class for all student events.
abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch students list.
class StudentsFetchRequested extends StudentsEvent {
  const StudentsFetchRequested({
    this.page = 1,
    this.search,
    this.refresh = false,
  });

  final int page;
  final String? search;
  final bool refresh;

  @override
  List<Object?> get props => [page, search, refresh];
}

/// Event to load more students (pagination).
class StudentsLoadMoreRequested extends StudentsEvent {
  const StudentsLoadMoreRequested();
}

/// Event to search students.
class StudentsSearchRequested extends StudentsEvent {
  const StudentsSearchRequested({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to clear search and reset to initial state.
class StudentsSearchCleared extends StudentsEvent {
  const StudentsSearchCleared();
}

/// Event to clear any error.
class StudentsErrorCleared extends StudentsEvent {
  const StudentsErrorCleared();
}
