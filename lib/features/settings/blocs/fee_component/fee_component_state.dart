import 'package:equatable/equatable.dart';

import '../../models/fee_component_model.dart';

/// Enum representing the status of fee component operations.
enum FeeComponentStatus { initial, loading, loadingMore, success, failure }

/// Enum representing the status of fee component CRUD operations.
enum FeeComponentActionStatus { idle, loading, success, failure }

/// State class for fee component feature.
class FeeComponentState extends Equatable {
  const FeeComponentState({
    this.status = FeeComponentStatus.initial,
    this.feeComponents = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.error,
    this.actionStatus = FeeComponentActionStatus.idle,
    this.actionError,
  });

  final FeeComponentStatus status;
  final List<FeeComponentModel> feeComponents;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final String? error;
  final FeeComponentActionStatus actionStatus;
  final String? actionError;

  /// Check if initial loading is in progress.
  bool get isLoading => status == FeeComponentStatus.loading;

  /// Check if loading more is in progress.
  bool get isLoadingMore => status == FeeComponentStatus.loadingMore;

  /// Check if there's an error.
  bool get hasError => status == FeeComponentStatus.failure;

  /// Check if data was loaded successfully.
  bool get isSuccess => status == FeeComponentStatus.success;

  /// Check if there are no fee components.
  bool get isEmpty =>
      feeComponents.isEmpty && status == FeeComponentStatus.success;

  /// Check if search is active.
  bool get isSearching => searchQuery.isNotEmpty;

  /// Check if an action is in progress.
  bool get isActionLoading => actionStatus == FeeComponentActionStatus.loading;

  /// Check if action was successful.
  bool get isActionSuccess => actionStatus == FeeComponentActionStatus.success;

  /// Check if action failed.
  bool get isActionFailure => actionStatus == FeeComponentActionStatus.failure;

  FeeComponentState copyWith({
    FeeComponentStatus? status,
    List<FeeComponentModel>? feeComponents,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    String? error,
    FeeComponentActionStatus? actionStatus,
    String? actionError,
  }) {
    return FeeComponentState(
      status: status ?? this.status,
      feeComponents: feeComponents ?? this.feeComponents,
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
    feeComponents,
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
