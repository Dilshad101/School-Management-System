import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/students_repository.dart';
import 'students_event.dart';
import 'students_state.dart';

/// BLoC for managing students list state.
class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  StudentsBloc({required StudentsRepository studentsRepository})
    : _studentsRepository = studentsRepository,
      super(const StudentsState()) {
    on<StudentsFetchRequested>(_onFetchRequested);
    on<StudentsLoadMoreRequested>(_onLoadMoreRequested);
    on<StudentsSearchRequested>(_onSearchRequested);
    on<StudentsSearchCleared>(_onSearchCleared);
    on<StudentsErrorCleared>(_onErrorCleared);
  }

  final StudentsRepository _studentsRepository;

  static const int _pageSize = 10;

  Future<void> _onFetchRequested(
    StudentsFetchRequested event,
    Emitter<StudentsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StudentsStatus.loading,
        searchQuery: event.search ?? state.searchQuery,
      ),
    );

    try {
      final response = await _studentsRepository.getStudents(
        page: event.page,
        pageSize: _pageSize,
        search: event.search ?? state.searchQuery,
      );

      emit(
        state.copyWith(
          status: StudentsStatus.success,
          students: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StudentsStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    StudentsLoadMoreRequested event,
    Emitter<StudentsState> emit,
  ) async {
    // Don't load more if already loading or no more data
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(status: StudentsStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _studentsRepository.getStudents(
        page: nextPage,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(
        state.copyWith(
          status: StudentsStatus.success,
          students: [...state.students, ...response.results],
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StudentsStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    StudentsSearchRequested event,
    Emitter<StudentsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StudentsStatus.loading,
        searchQuery: event.query,
        students: [],
      ),
    );

    try {
      final response = await _studentsRepository.getStudents(
        page: 1,
        pageSize: _pageSize,
        search: event.query.isNotEmpty ? event.query : null,
      );

      emit(
        state.copyWith(
          status: StudentsStatus.success,
          students: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StudentsStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onSearchCleared(
    StudentsSearchCleared event,
    Emitter<StudentsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StudentsStatus.loading,
        searchQuery: '',
        students: [],
      ),
    );

    try {
      final response = await _studentsRepository.getStudents(
        page: 1,
        pageSize: _pageSize,
      );

      emit(
        state.copyWith(
          status: StudentsStatus.success,
          students: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasNext,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StudentsStatus.failure, error: e.toString()));
    }
  }

  void _onErrorCleared(
    StudentsErrorCleared event,
    Emitter<StudentsState> emit,
  ) {
    emit(state.copyWith(status: StudentsStatus.success, error: null));
  }
}
