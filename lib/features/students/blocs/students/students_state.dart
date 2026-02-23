import 'package:equatable/equatable.dart';

import '../../models/student_model.dart';

/// Enum representing the status of students operations.
enum StudentsStatus {
  initial,
  loading,
  loadingMore,
  success,
  failure,
  deleting,
}

/// State class for students feature.
class StudentsState extends Equatable {
  const StudentsState({
    this.status = StudentsStatus.initial,
    this.students = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.error,
  });

  final StudentsStatus status;
  final List<StudentModel> students;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final String? error;

  /// Check if initial loading is in progress.
  bool get isLoading => status == StudentsStatus.loading;

  /// Check if loading more is in progress.
  bool get isLoadingMore => status == StudentsStatus.loadingMore;

  /// Check if deleting is in progress.
  bool get isDeleting => status == StudentsStatus.deleting;

  /// Check if there's an error.
  bool get hasError => status == StudentsStatus.failure;

  /// Check if data was loaded successfully.
  bool get isSuccess => status == StudentsStatus.success;

  /// Check if there are no students.
  bool get isEmpty => students.isEmpty && status == StudentsStatus.success;

  /// Check if search is active.
  bool get isSearching => searchQuery.isNotEmpty;

  StudentsState copyWith({
    StudentsStatus? status,
    List<StudentModel>? students,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    String? error,
  }) {
    return StudentsState(
      status: status ?? this.status,
      students: students ?? this.students,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    students,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
    searchQuery,
    error,
  ];
}
