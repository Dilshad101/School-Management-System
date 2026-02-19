import 'package:equatable/equatable.dart';

/// Base class for all employee list events.
sealed class EmployeesEvent extends Equatable {
  const EmployeesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch employees list.
class FetchEmployees extends EmployeesEvent {
  const FetchEmployees({this.page = 1, this.search, this.refresh = false});

  final int page;
  final String? search;
  final bool refresh;

  @override
  List<Object?> get props => [page, search, refresh];
}

/// Event to search employees.
class SearchEmployees extends EmployeesEvent {
  const SearchEmployees(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to load more employees (pagination).
class LoadMoreEmployees extends EmployeesEvent {
  const LoadMoreEmployees();
}

/// Event to refresh employees list.
class RefreshEmployees extends EmployeesEvent {
  const RefreshEmployees();
}

/// Event to delete an employee.
class DeleteEmployee extends EmployeesEvent {
  const DeleteEmployee(this.employeeId);

  final String employeeId;

  @override
  List<Object?> get props => [employeeId];
}

/// Event to clear error message.
class ClearEmployeesError extends EmployeesEvent {
  const ClearEmployeesError();
}
