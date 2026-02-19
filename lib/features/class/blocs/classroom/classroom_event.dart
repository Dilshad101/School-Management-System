import 'package:equatable/equatable.dart';

/// Base class for all classroom events.
sealed class ClassroomEvent extends Equatable {
  const ClassroomEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch classrooms list.
class FetchClassrooms extends ClassroomEvent {
  const FetchClassrooms({this.page = 1, this.search, this.refresh = false});

  final int page;
  final String? search;
  final bool refresh;

  @override
  List<Object?> get props => [page, search, refresh];
}

/// Event to search classrooms.
class SearchClassrooms extends ClassroomEvent {
  const SearchClassrooms(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to load more classrooms (pagination).
class LoadMoreClassrooms extends ClassroomEvent {
  const LoadMoreClassrooms();
}

/// Event to refresh classrooms list.
class RefreshClassrooms extends ClassroomEvent {
  const RefreshClassrooms();
}

/// Event to delete a classroom.
class DeleteClassroom extends ClassroomEvent {
  const DeleteClassroom(this.classroomId);

  final String classroomId;

  @override
  List<Object?> get props => [classroomId];
}

/// Event to clear error message.
class ClearClassroomError extends ClassroomEvent {
  const ClearClassroomError();
}
