import 'dart:io';

import 'package:equatable/equatable.dart';

/// Enum for notification audience type.
enum NotificationAudience {
  all('All'),
  students('Student'),
  employees('Employee'),
  guardians('Guardian');

  const NotificationAudience(this.label);
  final String label;
}

/// Enum for the submission status.
enum NotificationSubmissionStatus { initial, loading, success, failure }

/// Model for a notification item.
class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    required this.createdAt,
    this.className,
    this.division,
    this.attachment,
  });

  final String id;
  final String title;
  final String message;
  final NotificationAudience audience;
  final DateTime createdAt;
  final String? className;
  final String? division;
  final File? attachment;

  /// Get the color associated with each audience type.
  static int getAudienceColorValue(NotificationAudience audience) {
    switch (audience) {
      case NotificationAudience.all:
        return 0xFF10B981; // Green
      case NotificationAudience.students:
        return 0xFF3B82F6; // Blue
      case NotificationAudience.employees:
        return 0xFF6D5DD3; // Purple
      case NotificationAudience.guardians:
        return 0xFFEC4899; // Pink
    }
  }

  /// Get relative time string.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    audience,
    createdAt,
    className,
    division,
    attachment?.path,
  ];
}

/// Immutable state class for NotificationCubit.
class NotificationState extends Equatable {
  const NotificationState({
    this.isInitialLoading = true,
    this.submissionStatus = NotificationSubmissionStatus.initial,
    this.errorMessage,
    // Filter
    this.selectedFilter = NotificationAudience.all,
    // Notifications list
    this.notifications = const [],
    // Add notification form
    this.sentTo = NotificationAudience.all,
    this.selectedClass,
    this.selectedDivision,
    this.title = '',
    this.message = '',
    this.attachment,
    // Dropdown data (fetched from API)
    this.classes = const [],
    this.divisions = const [],
    this.audiences = const [],
  });

  // Loading states
  final bool isInitialLoading;
  final NotificationSubmissionStatus submissionStatus;
  final String? errorMessage;

  // Filter
  final NotificationAudience selectedFilter;

  // Notifications list
  final List<NotificationModel> notifications;

  // Add notification form fields
  final NotificationAudience sentTo;
  final String? selectedClass;
  final String? selectedDivision;
  final String title;
  final String message;
  final File? attachment;

  // Dropdown data
  final List<String> classes;
  final List<String> divisions;
  final List<NotificationAudience> audiences;

  /// Get filtered notifications based on selected filter.
  List<NotificationModel> get filteredNotifications {
    if (selectedFilter == NotificationAudience.all) {
      return notifications;
    }
    return notifications.where((n) => n.audience == selectedFilter).toList();
  }

  /// Check if form is valid for submission.
  bool get isFormValid => title.trim().isNotEmpty && message.trim().isNotEmpty;

  /// Check if currently submitting.
  bool get isSubmitting =>
      submissionStatus == NotificationSubmissionStatus.loading;

  NotificationState copyWith({
    bool? isInitialLoading,
    NotificationSubmissionStatus? submissionStatus,
    String? errorMessage,
    NotificationAudience? selectedFilter,
    List<NotificationModel>? notifications,
    NotificationAudience? sentTo,
    String? selectedClass,
    String? selectedDivision,
    String? title,
    String? message,
    File? attachment,
    List<String>? classes,
    List<String>? divisions,
    List<NotificationAudience>? audiences,
    bool clearAttachment = false,
    bool clearErrorMessage = false,
    bool clearSelectedClass = false,
    bool clearSelectedDivision = false,
  }) {
    return NotificationState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      notifications: notifications ?? this.notifications,
      sentTo: sentTo ?? this.sentTo,
      selectedClass: clearSelectedClass
          ? null
          : (selectedClass ?? this.selectedClass),
      selectedDivision: clearSelectedDivision
          ? null
          : (selectedDivision ?? this.selectedDivision),
      title: title ?? this.title,
      message: message ?? this.message,
      attachment: clearAttachment ? null : (attachment ?? this.attachment),
      classes: classes ?? this.classes,
      divisions: divisions ?? this.divisions,
      audiences: audiences ?? this.audiences,
    );
  }

  @override
  List<Object?> get props => [
    isInitialLoading,
    submissionStatus,
    errorMessage,
    selectedFilter,
    notifications,
    sentTo,
    selectedClass,
    selectedDivision,
    title,
    message,
    attachment?.path,
    classes,
    divisions,
    audiences,
  ];
}
