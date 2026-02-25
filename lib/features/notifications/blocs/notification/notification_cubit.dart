import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/tenant/tenant_context.dart';
import '../../../../core/utils/di.dart';
import '../../../students/models/class_room_model.dart';
import '../../../students/models/student_model.dart';
import '../../models/create_notification_request.dart';
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

  /// Add a class to selected classes.
  void addClass(ClassRoomModel classroom) {
    if (!state.selectedClasses.any((c) => c.id == classroom.id)) {
      final updatedClasses = [...state.selectedClasses, classroom];
      emit(state.copyWith(selectedClasses: updatedClasses));
    }
  }

  /// Remove a class from selected classes.
  void removeClass(ClassRoomModel classroom) {
    final updatedClasses = state.selectedClasses
        .where((c) => c.id != classroom.id)
        .toList();
    emit(state.copyWith(selectedClasses: updatedClasses));
  }

  /// Add a student to selected students.
  void addStudent(StudentModel student) {
    if (!state.selectedStudents.any((s) => s.id == student.id)) {
      final updatedStudents = [...state.selectedStudents, student];
      emit(state.copyWith(selectedStudents: updatedStudents));
    }
  }

  /// Remove a student from selected students.
  void removeStudent(StudentModel student) {
    final updatedStudents = state.selectedStudents
        .where((s) => s.id != student.id)
        .toList();
    emit(state.copyWith(selectedStudents: updatedStudents));
  }

  /// Update notification title.
  void updateTitle(String value) {
    emit(state.copyWith(title: value));
  }

  /// Update notification message.
  void updateMessage(String value) {
    emit(state.copyWith(message: value));
  }

  /// Update scheduled date time.
  void updateScheduledDateTime(DateTime? value) {
    if (value != null) {
      emit(state.copyWith(scheduledDateTime: value));
    } else {
      emit(state.copyWith(clearScheduledDateTime: true));
    }
  }

  // ==================== Search APIs ====================

  /// Search for classrooms.
  Future<List<ClassRoomModel>> searchClassrooms(String query) async {
    try {
      final response = await _repository.searchClassrooms(search: query);
      return response.results;
    } catch (e) {
      return [];
    }
  }

  /// Search for students.
  Future<List<StudentModel>> searchStudents(String query) async {
    try {
      final response = await _repository.searchStudents(search: query);
      return response.results;
    } catch (e) {
      return [];
    }
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
      final schoolId = locator<TenantContext>().selectedSchoolId;
      if (schoolId == null) {
        throw const ApiException(message: 'School ID not found');
      }

      final request = CreateNotificationRequest(
        title: state.title.trim(),
        message: state.message.trim(),
        notificationType: state.sentTo.apiValue,
        school: schoolId,
        attachment: state.attachment,
        dateTime: state.scheduledDateTime,
        classes: state.selectedClasses.map((c) => c.id).toList(),
        students: state.selectedStudents
            .map((s) => s.id ?? '')
            .where((id) => id.isNotEmpty)
            .toList(),
      );

      await _repository.createNotification(request);

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
        clearSelectedClasses: true,
        clearSelectedStudents: true,
        clearScheduledDateTime: true,
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
