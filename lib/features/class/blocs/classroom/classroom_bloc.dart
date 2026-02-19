import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/classroom_repository.dart';
import 'classroom_event.dart';
import 'classroom_state.dart';

export 'classroom_event.dart';
export 'classroom_state.dart';

/// BLoC for managing the classrooms list state.
class ClassroomBloc extends Bloc<ClassroomEvent, ClassroomState> {
  ClassroomBloc({required ClassroomRepository classroomRepository})
    : _classroomRepository = classroomRepository,
      super(const ClassroomState()) {
    on<FetchClassrooms>(_onFetchClassrooms);
    on<SearchClassrooms>(_onSearchClassrooms);
    on<LoadMoreClassrooms>(_onLoadMoreClassrooms);
    on<RefreshClassrooms>(_onRefreshClassrooms);
    on<DeleteClassroom>(_onDeleteClassroom);
    on<ClearClassroomError>(_onClearError);
  }

  final ClassroomRepository _classroomRepository;

  /// Debounce timer for search
  Timer? _searchDebounce;

  /// Handles fetching classrooms.
  Future<void> _onFetchClassrooms(
    FetchClassrooms event,
    Emitter<ClassroomState> emit,
  ) async {
    // Don't show loading if refreshing
    if (!event.refresh) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final response = await _classroomRepository.getClassrooms(
        page: event.page,
        search: event.search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: true,
          classrooms: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasNext: response.hasNext,
          hasPrevious: response.hasPrevious,
          searchQuery: event.search ?? state.searchQuery,
        ),
      );
    } on ApiException catch (e, s) {
      log('$e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e, s) {
      log('$e trace: $s');
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isSuccess: false,
          errorMessage: 'Failed to fetch classrooms. Please try again.',
        ),
      );
    }
  }

  /// Handles searching classrooms with debounce.
  Future<void> _onSearchClassrooms(
    SearchClassrooms event,
    Emitter<ClassroomState> emit,
  ) async {
    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    // Update search query immediately for UI feedback
    emit(state.copyWith(searchQuery: event.query));

    // Debounce the actual search
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(FetchClassrooms(page: 1, search: event.query));
    });
  }

  /// Handles loading more classrooms (pagination).
  Future<void> _onLoadMoreClassrooms(
    LoadMoreClassrooms event,
    Emitter<ClassroomState> emit,
  ) async {
    // Don't load more if already loading or no more pages
    if (!state.canLoadMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _classroomRepository.getClassrooms(
        page: nextPage,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      // Append new classrooms to existing list
      final updatedClassrooms = [...state.classrooms, ...response.results];

      emit(
        state.copyWith(
          isLoadingMore: false,
          classrooms: updatedClassrooms,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasNext: response.hasNext,
          hasPrevious: response.hasPrevious,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Failed to load more classrooms.',
        ),
      );
    }
  }

  /// Handles refreshing classrooms list.
  Future<void> _onRefreshClassrooms(
    RefreshClassrooms event,
    Emitter<ClassroomState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    add(
      FetchClassrooms(
        page: 1,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        refresh: true,
      ),
    );
  }

  /// Handles deleting a classroom.
  Future<void> _onDeleteClassroom(
    DeleteClassroom event,
    Emitter<ClassroomState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, clearError: true));

    try {
      await _classroomRepository.deleteClassroom(event.classroomId);

      // Remove the deleted classroom from the list
      final updatedClassrooms = state.classrooms
          .where((c) => c.id != event.classroomId)
          .toList();

      emit(
        state.copyWith(
          isDeleting: false,
          isSuccess: true,
          classrooms: updatedClassrooms,
          totalCount: state.totalCount - 1,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          isSuccess: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          isSuccess: false,
          errorMessage: 'Failed to delete classroom. Please try again.',
        ),
      );
    }
  }

  /// Clears error message.
  void _onClearError(ClearClassroomError event, Emitter<ClassroomState> emit) {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
