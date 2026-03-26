import 'package:equatable/equatable.dart';

import '../../models/student_fee_model.dart';

/// Enum representing the status of fees operations.
enum FeesStatus { initial, loading, loadingMore, success, failure }

/// State class for fees feature.
class FeesState extends Equatable {
  const FeesState({
    this.status = FeesStatus.initial,
    this.fees = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.error,
  });

  final FeesStatus status;
  final List<StudentFeeModel> fees;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final String? error;

  /// Check if initial loading is in progress.
  bool get isLoading => status == FeesStatus.loading;

  /// Check if loading more is in progress.
  bool get isLoadingMore => status == FeesStatus.loadingMore;

  /// Check if there's an error.
  bool get hasError => status == FeesStatus.failure;

  /// Check if data was loaded successfully.
  bool get isSuccess => status == FeesStatus.success;

  /// Check if there are no fees.
  bool get isEmpty => fees.isEmpty && status == FeesStatus.success;

  /// Check if search is active.
  bool get isSearching => searchQuery.isNotEmpty;

  FeesState copyWith({
    FeesStatus? status,
    List<StudentFeeModel>? fees,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    String? error,
  }) {
    return FeesState(
      status: status ?? this.status,
      fees: fees ?? this.fees,
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
    fees,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
    searchQuery,
    error,
  ];
}
