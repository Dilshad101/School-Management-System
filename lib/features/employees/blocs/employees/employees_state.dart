import 'package:equatable/equatable.dart';

import '../../models/employee_model.dart';

/// Immutable state class for EmployeesBloc.
class EmployeesState extends Equatable {
  const EmployeesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isDeleting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.employees = const [],
    this.searchQuery = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  /// Loading state for initial fetch.
  final bool isLoading;

  /// Loading state for pagination.
  final bool isLoadingMore;

  /// Loading state for pull-to-refresh.
  final bool isRefreshing;

  /// Loading state for delete operation.
  final bool isDeleting;

  /// Success state after a successful operation.
  final bool isSuccess;

  /// Error message if an operation fails.
  final String? errorMessage;

  /// List of employees.
  final List<EmployeeModel> employees;

  /// Current search query.
  final String searchQuery;

  /// Current page number.
  final int currentPage;

  /// Total number of pages.
  final int totalPages;

  /// Total count of employees.
  final int totalCount;

  /// Whether there's a next page.
  final bool hasNext;

  /// Whether there's a previous page.
  final bool hasPrevious;

  /// Helper getters
  bool get hasError => errorMessage != null;
  bool get isEmpty => employees.isEmpty && !isLoading;
  bool get hasData => employees.isNotEmpty;
  bool get canLoadMore => hasNext && !isLoadingMore && !isLoading;

  /// Creates a copy of this state with the given fields replaced.
  EmployeesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isDeleting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
    List<EmployeeModel>? employees,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    return EmployeesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDeleting: isDeleting ?? this.isDeleting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      employees: employees ?? this.employees,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    isRefreshing,
    isDeleting,
    isSuccess,
    errorMessage,
    employees,
    searchQuery,
    currentPage,
    totalPages,
    totalCount,
    hasNext,
    hasPrevious,
  ];
}
