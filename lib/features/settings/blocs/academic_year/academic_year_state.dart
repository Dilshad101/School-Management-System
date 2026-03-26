import 'package:equatable/equatable.dart';

import '../../models/academic_year_model.dart';

/// Enum representing the status of academic year operations.
enum AcademicYearStatus { initial, loading, loadingMore, success, failure }

/// Enum representing the status of academic year CRUD operations.
enum AcademicYearActionStatus { idle, loading, success, failure }

/// State class for academic year feature.
class AcademicYearState extends Equatable {
  const AcademicYearState({
    this.status = AcademicYearStatus.initial,
    this.academicYears = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.error,
    this.actionStatus = AcademicYearActionStatus.idle,
    this.actionError,
  });

  final AcademicYearStatus status;
  final List<AcademicYearModel> academicYears;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final String? error;
  final AcademicYearActionStatus actionStatus;
  final String? actionError;

  /// Check if initial loading is in progress.
  bool get isLoading => status == AcademicYearStatus.loading;

  /// Check if loading more is in progress.
  bool get isLoadingMore => status == AcademicYearStatus.loadingMore;

  /// Check if there's an error.
  bool get hasError => status == AcademicYearStatus.failure;

  /// Check if data was loaded successfully.
  bool get isSuccess => status == AcademicYearStatus.success;

  /// Check if there are no academic years.
  bool get isEmpty =>
      academicYears.isEmpty && status == AcademicYearStatus.success;

  /// Check if search is active.
  bool get isSearching => searchQuery.isNotEmpty;

  /// Check if an action is in progress.
  bool get isActionLoading => actionStatus == AcademicYearActionStatus.loading;

  /// Check if action was successful.
  bool get isActionSuccess => actionStatus == AcademicYearActionStatus.success;

  /// Check if action failed.
  bool get isActionFailure => actionStatus == AcademicYearActionStatus.failure;

  AcademicYearState copyWith({
    AcademicYearStatus? status,
    List<AcademicYearModel>? academicYears,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    String? error,
    AcademicYearActionStatus? actionStatus,
    String? actionError,
  }) {
    return AcademicYearState(
      status: status ?? this.status,
      academicYears: academicYears ?? this.academicYears,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    academicYears,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
    searchQuery,
    error,
    actionStatus,
    actionError,
  ];
}
