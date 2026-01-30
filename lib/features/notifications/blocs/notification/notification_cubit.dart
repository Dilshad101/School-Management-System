import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification_state.dart';

export 'notification_state.dart';

/// Cubit for managing notifications state.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationState());

  /// Initialize and fetch all data.
  Future<void> initialize() async {
    emit(state.copyWith(isInitialLoading: true));

    try {
      // Simulate parallel API calls
      final results = await Future.wait([
        _fetchNotifications(),
        _fetchClasses(),
        _fetchDivisions(),
      ]);

      final notifications = results[0] as List<NotificationModel>;
      final classes = results[1] as List<String>;
      final divisions = results[2] as List<String>;

      emit(
        state.copyWith(
          isInitialLoading: false,
          notifications: notifications,
          classes: classes,
          divisions: divisions,
          audiences: NotificationAudience.values,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load notifications. Please try again.',
        ),
      );
    }
  }

  /// Simulates fetching notifications from API.
  Future<List<NotificationModel>> _fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'Update',
        message: 'Please update student and staff details for this month.',
        audience: NotificationAudience.students,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: '2',
        title: 'Update',
        message: 'Please update student and staff details for this month.',
        audience: NotificationAudience.students,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: '3',
        title: 'Update',
        message: 'Please update student and staff details for this month.',
        audience: NotificationAudience.guardians,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: '4',
        title: 'Update',
        message: 'Please update student and staff details for this month.',
        audience: NotificationAudience.all,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: '5',
        title: 'Update',
        message: 'Please update student and staff details for this month.',
        audience: NotificationAudience.employees,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: '6',
        title: 'Update',
        message: 'Please update student and staff details for this month.',
        audience: NotificationAudience.all,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: '7',
        title: 'Update',
        message: 'Please update student and staff details for this month.',
        audience: NotificationAudience.employees,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  /// Simulates fetching classes from API.
  Future<List<String>> _fetchClasses() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'];
  }

  /// Simulates fetching divisions from API.
  Future<List<String>> _fetchDivisions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['Division A', 'Division B', 'Division C'];
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Create new notification
      final newNotification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: state.title,
        message: state.message,
        audience: state.sentTo,
        createdAt: DateTime.now(),
        className: state.selectedClass,
        division: state.selectedDivision,
        attachment: state.attachment,
      );

      // Add to the beginning of the list
      final updatedNotifications = [newNotification, ...state.notifications];

      emit(
        state.copyWith(
          submissionStatus: NotificationSubmissionStatus.success,
          notifications: updatedNotifications,
        ),
      );

      return true;
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
