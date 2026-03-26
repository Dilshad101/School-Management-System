import 'package:equatable/equatable.dart';

import '../../models/subject_model.dart';

/// Enum representing the status of subject operations.
enum SubjectStatus { initial, loading, loadingMore, success, failure }

/// Enum representing the status of subject CRUD operations.
enum SubjectActionStatus { idle, loading, success, failure }

/// State class for subject feature.
class SubjectState extends Equatable {
  const SubjectState({
    this.status = SubjectStatus.initial,
    this.subjects = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.error,
    this.actionStatus = SubjectActionStatus.idle,
    this.actionError,
  });

  final SubjectStatus status;
  final List<SubjectModel> subjects;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final String? error;
  final SubjectActionStatus actionStatus;
  final String? actionError;

  /// Check if initial loading is in progress.
  bool get isLoading => status == SubjectStatus.loading;

  /// Check if loading more is in progress.
  bool get isLoadingMore => status == SubjectStatus.loadingMore;

  /// Check if there's an error.
  bool get hasError => status == SubjectStatus.failure;

  /// Check if data was loaded successfully.
  bool get isSuccess => status == SubjectStatus.success;

  /// Check if there are no subjects.
  bool get isEmpty => subjects.isEmpty && status == SubjectStatus.success;

  /// Check if search is active.
  bool get isSearching => searchQuery.isNotEmpty;

  /// Check if an action is in progress.
  bool get isActionLoading => actionStatus == SubjectActionStatus.loading;

  /// Check if action was successful.
  bool get isActionSuccess => actionStatus == SubjectActionStatus.success;

  /// Check if action failed.
  bool get isActionFailure => actionStatus == SubjectActionStatus.failure;

  SubjectState copyWith({
    SubjectStatus? status,
    List<SubjectModel>? subjects,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    String? error,
    SubjectActionStatus? actionStatus,
    String? actionError,
  }) {
    return SubjectState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
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
    subjects,
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
