import 'package:equatable/equatable.dart';

import '../../models/guardian_model.dart';

/// Enum representing the status of guardians operations.
enum GuardiansStatus {
  initial,
  loading,
  loadingMore,
  success,
  failure,
  deleting,
  deleteSuccess,
  deleteFailure,
}

/// State class for guardians feature.
class GuardiansState extends Equatable {
  const GuardiansState({
    this.status = GuardiansStatus.initial,
    this.guardians = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.selectedClassId,
    this.selectedDivisionId,
    this.error,
    this.successMessage,
  });

  final GuardiansStatus status;
  final List<GuardianModel> guardians;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final String? selectedClassId;
  final String? selectedDivisionId;
  final String? error;
  final String? successMessage;

  /// Check if initial loading is in progress.
  bool get isLoading => status == GuardiansStatus.loading;

  /// Check if loading more is in progress.
  bool get isLoadingMore => status == GuardiansStatus.loadingMore;

  /// Check if there's an error.
  bool get hasError => status == GuardiansStatus.failure;

  /// Check if data was loaded successfully.
  bool get isSuccess => status == GuardiansStatus.success;

  /// Check if there are no guardians.
  bool get isEmpty => guardians.isEmpty && status == GuardiansStatus.success;

  /// Check if search is active.
  bool get isSearching => searchQuery.isNotEmpty;

  /// Check if any filter is active.
  bool get hasActiveFilters =>
      selectedClassId != null || selectedDivisionId != null;

  /// Check if deleting.
  bool get isDeleting => status == GuardiansStatus.deleting;

  GuardiansState copyWith({
    GuardiansStatus? status,
    List<GuardianModel>? guardians,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    String? selectedClassId,
    String? selectedDivisionId,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearClassFilter = false,
    bool clearDivisionFilter = false,
  }) {
    return GuardiansState(
      status: status ?? this.status,
      guardians: guardians ?? this.guardians,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedClassId: clearClassFilter
          ? null
          : (selectedClassId ?? this.selectedClassId),
      selectedDivisionId: clearDivisionFilter
          ? null
          : (selectedDivisionId ?? this.selectedDivisionId),
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    guardians,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
    searchQuery,
    selectedClassId,
    selectedDivisionId,
    error,
    successMessage,
  ];
}
