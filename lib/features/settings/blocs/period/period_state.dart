import 'package:equatable/equatable.dart';

import '../../models/period_model.dart';

/// Enum representing the status of period operations.
enum PeriodStatus { initial, loading, loadingMore, success, failure }

/// Enum representing the status of period CRUD operations.
enum PeriodActionStatus { idle, loading, success, failure }

/// State class for period feature.
class PeriodState extends Equatable {
  const PeriodState({
    this.status = PeriodStatus.initial,
    this.periods = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.error,
    this.actionStatus = PeriodActionStatus.idle,
    this.actionError,
  });

  final PeriodStatus status;
  final List<PeriodModel> periods;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final String? error;
  final PeriodActionStatus actionStatus;
  final String? actionError;

  /// Check if initial loading is in progress.
  bool get isLoading => status == PeriodStatus.loading;

  /// Check if loading more is in progress.
  bool get isLoadingMore => status == PeriodStatus.loadingMore;

  /// Check if there's an error.
  bool get hasError => status == PeriodStatus.failure;

  /// Check if data was loaded successfully.
  bool get isSuccess => status == PeriodStatus.success;

  /// Check if there are no periods.
  bool get isEmpty => periods.isEmpty && status == PeriodStatus.success;

  /// Check if search is active.
  bool get isSearching => searchQuery.isNotEmpty;

  /// Check if an action is in progress.
  bool get isActionLoading => actionStatus == PeriodActionStatus.loading;

  /// Check if action was successful.
  bool get isActionSuccess => actionStatus == PeriodActionStatus.success;

  /// Check if action failed.
  bool get isActionFailure => actionStatus == PeriodActionStatus.failure;

  PeriodState copyWith({
    PeriodStatus? status,
    List<PeriodModel>? periods,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    String? error,
    PeriodActionStatus? actionStatus,
    String? actionError,
  }) {
    return PeriodState(
      status: status ?? this.status,
      periods: periods ?? this.periods,
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
    periods,
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
