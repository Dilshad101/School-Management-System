import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/fees_repository.dart';
import 'fees_event.dart';
import 'fees_state.dart';

/// BLoC for managing fees list state.
class FeesBloc extends Bloc<FeesEvent, FeesState> {
  FeesBloc({required FeesRepository feesRepository})
    : _feesRepository = feesRepository,
      super(const FeesState()) {
    on<FeesFetchRequested>(_onFetchRequested);
    on<FeesLoadMoreRequested>(_onLoadMoreRequested);
    on<FeesSearchRequested>(_onSearchRequested);
    on<FeesSearchCleared>(_onSearchCleared);
    on<FeesErrorCleared>(_onErrorCleared);
  }

  final FeesRepository _feesRepository;

  static const int _pageSize = 10;

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> _onFetchRequested(
    FeesFetchRequested event,
    Emitter<FeesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FeesStatus.loading,
        searchQuery: event.search ?? state.searchQuery,
      ),
    );

    try {
      final response = await _feesRepository.getStudentFees(
        page: event.page,
        pageSize: _pageSize,
        search: event.search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          status: FeesStatus.success,
          fees: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: FeesStatus.failure, error: _getErrorMessage(e)),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    FeesLoadMoreRequested event,
    Emitter<FeesState> emit,
  ) async {
    // Don't load more if already loading or no more data
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(status: FeesStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _feesRepository.getStudentFees(
        page: nextPage,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(
        state.copyWith(
          status: FeesStatus.success,
          fees: [...state.fees, ...response.results],
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      // On load more failure, keep existing data but show error
      emit(
        state.copyWith(status: FeesStatus.success, error: _getErrorMessage(e)),
      );
    }
  }

  Future<void> _onSearchRequested(
    FeesSearchRequested event,
    Emitter<FeesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FeesStatus.loading,
        searchQuery: event.query,
        fees: [],
      ),
    );

    try {
      final response = await _feesRepository.getStudentFees(
        page: 1,
        pageSize: _pageSize,
        search: event.query.isNotEmpty ? event.query : null,
      );

      emit(
        state.copyWith(
          status: FeesStatus.success,
          fees: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: FeesStatus.failure, error: _getErrorMessage(e)),
      );
    }
  }

  Future<void> _onSearchCleared(
    FeesSearchCleared event,
    Emitter<FeesState> emit,
  ) async {
    emit(state.copyWith(status: FeesStatus.loading, searchQuery: '', fees: []));

    try {
      final response = await _feesRepository.getStudentFees(
        page: 1,
        pageSize: _pageSize,
      );

      emit(
        state.copyWith(
          status: FeesStatus.success,
          fees: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: FeesStatus.failure, error: _getErrorMessage(e)),
      );
    }
  }

  void _onErrorCleared(FeesErrorCleared event, Emitter<FeesState> emit) {
    emit(state.copyWith(error: null));
  }
}
