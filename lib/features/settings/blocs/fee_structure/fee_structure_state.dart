import 'package:equatable/equatable.dart';

import '../../models/fee_structure_model.dart';

enum FeeStructureStatus { initial, loading, success, failure }

enum FeeStructureActionStatus { idle, loading, success, failure }

class FeeStructureState extends Equatable {
  const FeeStructureState({
    this.status = FeeStructureStatus.initial,
    this.feeStructures = const [],
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.actionStatus = FeeStructureActionStatus.idle,
    this.actionError,
  });

  final FeeStructureStatus status;
  final List<FeeStructureModel> feeStructures;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final FeeStructureActionStatus actionStatus;
  final String? actionError;

  // Convenience getters
  bool get isLoading => status == FeeStructureStatus.loading;
  bool get isSuccess => status == FeeStructureStatus.success;
  bool get hasError => status == FeeStructureStatus.failure;
  bool get isEmpty => feeStructures.isEmpty && isSuccess;

  bool get isActionLoading => actionStatus == FeeStructureActionStatus.loading;
  bool get isActionSuccess => actionStatus == FeeStructureActionStatus.success;
  bool get isActionFailure => actionStatus == FeeStructureActionStatus.failure;

  FeeStructureState copyWith({
    FeeStructureStatus? status,
    List<FeeStructureModel>? feeStructures,
    String? error,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    FeeStructureActionStatus? actionStatus,
    String? actionError,
  }) {
    return FeeStructureState(
      status: status ?? this.status,
      feeStructures: feeStructures ?? this.feeStructures,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError ?? this.actionError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    feeStructures,
    error,
    currentPage,
    hasMore,
    isLoadingMore,
    actionStatus,
    actionError,
  ];
}
