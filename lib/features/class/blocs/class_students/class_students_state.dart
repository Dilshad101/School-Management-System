import 'package:equatable/equatable.dart';

import '../../../students/models/student_model.dart';

enum ClassStudentsStatus { initial, loading, loadingMore, success, failure }

class ClassStudentsState extends Equatable {
  const ClassStudentsState({
    this.status = ClassStudentsStatus.initial,
    this.students = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.error,
  });

  final ClassStudentsStatus status;
  final List<StudentModel> students;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final String? error;

  bool get isLoading => status == ClassStudentsStatus.loading;
  bool get isLoadingMore => status == ClassStudentsStatus.loadingMore;
  bool get hasError => status == ClassStudentsStatus.failure;
  bool get isEmpty => students.isEmpty && status == ClassStudentsStatus.success;

  ClassStudentsState copyWith({
    ClassStudentsStatus? status,
    List<StudentModel>? students,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    String? error,
    bool clearError = false,
  }) {
    return ClassStudentsState(
      status: status ?? this.status,
      students: students ?? this.students,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
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
