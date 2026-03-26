import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../models/fee_component_model.dart';
import '../../repositories/fee_component_repository.dart';
import 'fee_component_state.dart';

/// Cubit for managing fee component state.
class FeeComponentCubit extends Cubit<FeeComponentState> {
  FeeComponentCubit({
    required FeeComponentRepository feeComponentRepository,
    required String schoolId,
  }) : _feeComponentRepository = feeComponentRepository,
       _schoolId = schoolId,
       super(const FeeComponentState());

  final FeeComponentRepository _feeComponentRepository;
  final String _schoolId;

  static const int _pageSize = 10;

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Fetches the initial list of fee components.
  Future<void> fetchFeeComponents({String? search}) async {
    emit(
      state.copyWith(
        status: FeeComponentStatus.loading,
        searchQuery: search ?? state.searchQuery,
      ),
    );

    try {
      final response = await _feeComponentRepository.getFeeComponents(
        page: 1,
        pageSize: _pageSize,
        search: search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          status: FeeComponentStatus.success,
          feeComponents: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FeeComponentStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Loads more fee components (pagination).
  Future<void> loadMoreFeeComponents() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(status: FeeComponentStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _feeComponentRepository.getFeeComponents(
        page: nextPage,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(
        state.copyWith(
          status: FeeComponentStatus.success,
          feeComponents: [...state.feeComponents, ...response.results],
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FeeComponentStatus.success,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Creates a new fee component.
  Future<bool> createFeeComponent({
    required String name,
    required FeeFrequency frequency,
    required bool isOptional,
  }) async {
    emit(state.copyWith(actionStatus: FeeComponentActionStatus.loading));

    try {
      final newFeeComponent = await _feeComponentRepository.createFeeComponent(
        name: name,
        frequency: frequency.value,
        isOptional: isOptional,
        schoolId: _schoolId,
      );

      // Add the new fee component to the list
      final updatedList = [...state.feeComponents, newFeeComponent];
      // Sort by name
      updatedList.sort((a, b) => a.name.compareTo(b.name));

      emit(
        state.copyWith(
          actionStatus: FeeComponentActionStatus.success,
          feeComponents: updatedList,
          totalCount: state.totalCount + 1,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: FeeComponentActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Updates an existing fee component.
  Future<bool> updateFeeComponent({
    required String id,
    required String name,
    required FeeFrequency frequency,
    required bool isOptional,
  }) async {
    emit(state.copyWith(actionStatus: FeeComponentActionStatus.loading));

    try {
      final updatedFeeComponent = await _feeComponentRepository
          .updateFeeComponent(
            id: id,
            name: name,
            frequency: frequency.value,
            isOptional: isOptional,
          );

      // Update the fee component in the list
      final updatedList = state.feeComponents.map((item) {
        return item.id == id ? updatedFeeComponent : item;
      }).toList();
      // Sort by name
      updatedList.sort((a, b) => a.name.compareTo(b.name));

      emit(
        state.copyWith(
          actionStatus: FeeComponentActionStatus.success,
          feeComponents: updatedList,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: FeeComponentActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Deletes a fee component.
  Future<bool> deleteFeeComponent({required String id}) async {
    emit(state.copyWith(actionStatus: FeeComponentActionStatus.loading));

    try {
      await _feeComponentRepository.deleteFeeComponent(id: id);

      // Remove the fee component from the list
      final updatedList = state.feeComponents
          .where((item) => item.id != id)
          .toList();

      emit(
        state.copyWith(
          actionStatus: FeeComponentActionStatus.success,
          feeComponents: updatedList,
          totalCount: state.totalCount - 1,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: FeeComponentActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Clears the action status.
  void clearActionStatus() {
    emit(
      state.copyWith(
        actionStatus: FeeComponentActionStatus.idle,
        actionError: null,
      ),
    );
  }

  /// Clears any error.
  void clearError() {
    emit(state.copyWith(error: null));
  }
}
