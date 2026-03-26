import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/fee_structure_repository.dart';
import 'fee_structure_state.dart';

class FeeStructureCubit extends Cubit<FeeStructureState> {
  FeeStructureCubit({
    required FeeStructureRepository feeStructureRepository,
    required this.schoolId,
  }) : _feeStructureRepository = feeStructureRepository,
       super(const FeeStructureState());

  final FeeStructureRepository _feeStructureRepository;
  final String schoolId;

  static const int _pageSize = 10;

  /// Fetches the initial list of fee structures.
  Future<void> fetchFeeStructures() async {
    emit(state.copyWith(status: FeeStructureStatus.loading));

    try {
      final response = await _feeStructureRepository.getFeeStructures(
        page: 1,
        pageSize: _pageSize,
      );

      emit(
        state.copyWith(
          status: FeeStructureStatus.success,
          feeStructures: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: FeeStructureStatus.failure, error: e.toString()),
      );
    }
  }

  /// Loads more fee structures for pagination.
  Future<void> loadMoreFeeStructures() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _feeStructureRepository.getFeeStructures(
        page: nextPage,
        pageSize: _pageSize,
      );

      emit(
        state.copyWith(
          feeStructures: [...state.feeStructures, ...response.results],
          currentPage: nextPage,
          hasMore: response.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  /// Creates a new fee structure.
  Future<void> createFeeStructure({
    required String name,
    required String classroomId,
    required String academicYearId,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(state.copyWith(actionStatus: FeeStructureActionStatus.loading));

    try {
      final newFeeStructure = await _feeStructureRepository.createFeeStructure(
        name: name,
        classroomId: classroomId,
        academicYearId: academicYearId,
        items: items,
        schoolId: schoolId,
      );

      emit(
        state.copyWith(
          feeStructures: [newFeeStructure, ...state.feeStructures],
          actionStatus: FeeStructureActionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: FeeStructureActionStatus.failure,
          actionError: e.toString(),
        ),
      );
    }
  }

  /// Updates an existing fee structure.
  Future<void> updateFeeStructure({
    required String id,
    required String name,
    required String classroomId,
    required String academicYearId,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(state.copyWith(actionStatus: FeeStructureActionStatus.loading));

    try {
      final updatedFeeStructure = await _feeStructureRepository
          .updateFeeStructure(
            id: id,
            name: name,
            classroomId: classroomId,
            academicYearId: academicYearId,
            items: items,
          );

      final updatedList = state.feeStructures.map((feeStructure) {
        return feeStructure.id == id ? updatedFeeStructure : feeStructure;
      }).toList();

      emit(
        state.copyWith(
          feeStructures: updatedList,
          actionStatus: FeeStructureActionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: FeeStructureActionStatus.failure,
          actionError: e.toString(),
        ),
      );
    }
  }

  /// Deletes a fee structure.
  Future<void> deleteFeeStructure({required String id}) async {
    emit(state.copyWith(actionStatus: FeeStructureActionStatus.loading));

    try {
      await _feeStructureRepository.deleteFeeStructure(id: id);

      final updatedList = state.feeStructures
          .where((feeStructure) => feeStructure.id != id)
          .toList();

      emit(
        state.copyWith(
          feeStructures: updatedList,
          actionStatus: FeeStructureActionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: FeeStructureActionStatus.failure,
          actionError: e.toString(),
        ),
      );
    }
  }

  /// Clears the action status.
  void clearActionStatus() {
    emit(
      state.copyWith(
        actionStatus: FeeStructureActionStatus.idle,
        actionError: null,
      ),
    );
  }
}
