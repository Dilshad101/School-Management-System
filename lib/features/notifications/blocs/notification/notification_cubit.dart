import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../repositories/notification_repository.dart';
import 'notification_state.dart';

export 'notification_state.dart';

/// Cubit for managing notifications state.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required NotificationRepository repository})
    : _repository = repository,
      super(const NotificationState());

  final NotificationRepository _repository;

  /// Default page size for pagination.
  static const int _pageSize = 10;

  /// Initialize and fetch initial data.
  Future<void> initialize() async {
    emit(
      state.copyWith(
        loadStatus: NotificationLoadStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final response = await _repository.getNotifications(
        page: 1,
        pageSize: _pageSize,
      );

      emit(
        state.copyWith(
          loadStatus: NotificationLoadStatus.success,
          notifications: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasMore,
          audiences: NotificationAudience.values,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loadStatus: NotificationLoadStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: NotificationLoadStatus.failure,
          errorMessage: 'Failed to load notifications. Please try again.',
        ),
      );
    }
  }

  /// Refresh notifications (pull to refresh).
  Future<void> refresh() async {
    emit(
      state.copyWith(
        loadStatus: NotificationLoadStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final response = await _repository.getNotifications(
        page: 1,
        pageSize: _pageSize,
      );

      emit(
        state.copyWith(
          loadStatus: NotificationLoadStatus.success,
          notifications: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasMore,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loadStatus: NotificationLoadStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: NotificationLoadStatus.failure,
          errorMessage: 'Failed to refresh notifications. Please try again.',
        ),
      );
    }
  }

  /// Load more notifications (pagination).
  Future<void> loadMore() async {
    // Prevent multiple simultaneous load more requests.
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getNotifications(
        page: nextPage,
        pageSize: _pageSize,
      );

      // Append new notifications to existing list.
      final updatedNotifications = [
        ...state.notifications,
        ...response.results,
      ];

      emit(
        state.copyWith(
          isLoadingMore: false,
          notifications: updatedNotifications,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalCount: response.count,
          hasMore: response.hasMore,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Failed to load more notifications.',
        ),
      );
    }
  }

  // ==================== Filter ====================

  /// Update the selected filter.
  void updateFilter(NotificationAudience filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  // ==================== Form Field Updates ====================

  /// Update the 'sent to' audience.
  void updateSentTo(NotificationAudience? audience) {
    if (audience != null) {
      emit(state.copyWith(sentTo: audience));
    }
  }

  /// Update selected class.
  void updateSelectedClass(String? value) {
    emit(
      state.copyWith(selectedClass: value, clearSelectedClass: value == null),
    );
  }

  /// Update selected division.
  void updateSelectedDivision(String? value) {
    emit(
      state.copyWith(
        selectedDivision: value,
        clearSelectedDivision: value == null,
      ),
    );
  }

  /// Update notification title.
  void updateTitle(String value) {
    emit(state.copyWith(title: value));
  }

  /// Update notification message.
  void updateMessage(String value) {
    emit(state.copyWith(message: value));
  }

  // ==================== Attachment ====================

  /// Pick attachment file.
  Future<void> pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          emit(state.copyWith(attachment: File(path)));
        }
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick file'));
    }
  }

  /// Remove attachment.
  void removeAttachment() {
    emit(state.copyWith(clearAttachment: true));
  }

  // ==================== Form Submission ====================

  /// Submit the notification form.
  Future<bool> submitNotification() async {
    if (!state.isFormValid) {
      emit(state.copyWith(errorMessage: 'Please fill all required fields'));
      return false;
    }

    emit(
      state.copyWith(
        submissionStatus: NotificationSubmissionStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      // TODO: Implement actual API call when endpoint is available
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 2));

      emit(
        state.copyWith(submissionStatus: NotificationSubmissionStatus.success),
      );

      // Refresh notifications to get the newly created one
      await refresh();

      return true;
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          submissionStatus: NotificationSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: NotificationSubmissionStatus.failure,
          errorMessage: 'Failed to send notification. Please try again.',
        ),
      );
      return false;
    }
  }

  /// Reset the form for adding another notification.
  void resetForm() {
    emit(
      state.copyWith(
        submissionStatus: NotificationSubmissionStatus.initial,
        sentTo: NotificationAudience.all,
        clearSelectedClass: true,
        clearSelectedDivision: true,
        title: '',
        message: '',
        clearAttachment: true,
        clearErrorMessage: true,
      ),
    );
  }

  /// Clear any error message.
  void clearError() {
    emit(state.copyWith(clearErrorMessage: true));
  }

  /// Reset submission status.
  void resetSubmissionStatus() {
    emit(
      state.copyWith(submissionStatus: NotificationSubmissionStatus.initial),
    );
  }
}
