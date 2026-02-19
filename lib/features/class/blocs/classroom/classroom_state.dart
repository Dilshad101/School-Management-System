import 'package:equatable/equatable.dart';

import '../../models/classroom_model.dart';

/// Immutable state class for ClassroomBloc.
class ClassroomState extends Equatable {
  const ClassroomState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isDeleting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.classrooms = const [],
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

  /// List of classrooms.
  final List<ClassroomModel> classrooms;

  /// Current search query.
  final String searchQuery;

  /// Current page number.
  final int currentPage;

  /// Total number of pages.
  final int totalPages;

  /// Total count of classrooms.
  final int totalCount;

  /// Whether there's a next page.
  final bool hasNext;

  /// Whether there's a previous page.
  final bool hasPrevious;

  /// Helper getters
  bool get hasError => errorMessage != null;
  bool get isEmpty => classrooms.isEmpty && !isLoading;
  bool get hasData => classrooms.isNotEmpty;
  bool get canLoadMore => hasNext && !isLoadingMore && !isLoading;

  /// Creates a copy of this state with the given fields replaced.
  ClassroomState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isDeleting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
    List<ClassroomModel>? classrooms,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    return ClassroomState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDeleting: isDeleting ?? this.isDeleting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      classrooms: classrooms ?? this.classrooms,
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
    classrooms,
    searchQuery,
    currentPage,
    totalPages,
    totalCount,
    hasNext,
    hasPrevious,
  ];
}
