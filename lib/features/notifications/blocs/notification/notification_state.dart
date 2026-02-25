import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../students/models/class_room_model.dart';
import '../../../students/models/student_model.dart';
import '../../models/notification_models.dart';

export '../../models/notification_models.dart';

/// Enum for data loading status.
enum NotificationLoadStatus { initial, loading, success, failure }

/// Enum for the submission status.
enum NotificationSubmissionStatus { initial, loading, success, failure }

/// Immutable state class for NotificationCubit.
class NotificationState extends Equatable {
  const NotificationState({
    // Loading states
    this.loadStatus = NotificationLoadStatus.initial,
    this.isLoadingMore = false,
    this.submissionStatus = NotificationSubmissionStatus.initial,
    this.errorMessage,
    // Filter
    this.selectedFilter = NotificationAudience.all,
    // Notifications list
    this.notifications = const [],
    // Pagination
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    // Add notification form fields
    this.sentTo = NotificationAudience.all,
    this.selectedClasses = const [],
    this.selectedStudents = const [],
    this.title = '',
    this.message = '',
    this.attachment,
    this.scheduledDateTime,
    // Dropdown data (fetched from API)
    this.audiences = const [],
  });

  // Loading states
  final NotificationLoadStatus loadStatus;
  final bool isLoadingMore;
  final NotificationSubmissionStatus submissionStatus;
  final String? errorMessage;

  // Filter
  final NotificationAudience selectedFilter;

  // Notifications list
  final List<NotificationModel> notifications;

  // Pagination
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  // Add notification form fields
  final NotificationAudience sentTo;
  final List<ClassRoomModel> selectedClasses;
  final List<StudentModel> selectedStudents;
  final String title;
  final String message;
  final File? attachment;
  final DateTime? scheduledDateTime;

  // Dropdown data
  final List<NotificationAudience> audiences;

  /// Check if initial loading.
  bool get isInitialLoading => loadStatus == NotificationLoadStatus.loading;

  /// Check if loading (initial or more).
  bool get isLoading =>
      loadStatus == NotificationLoadStatus.loading || isLoadingMore;

  /// Check if load was successful.
  bool get isSuccess => loadStatus == NotificationLoadStatus.success;

  /// Check if load failed.
  bool get isFailure => loadStatus == NotificationLoadStatus.failure;

  /// Get filtered notifications based on selected filter.
  List<NotificationModel> get filteredNotifications {
    if (selectedFilter == NotificationAudience.all) {
      return notifications;
    }
    return notifications
        .where((n) => n.notificationType == selectedFilter)
        .toList();
  }

  /// Check if form is valid for submission.
  /// Required fields: Sent To, Title, Message
  bool get isFormValid => title.trim().isNotEmpty && message.trim().isNotEmpty;

  /// Check if currently submitting.
  bool get isSubmitting =>
      submissionStatus == NotificationSubmissionStatus.loading;

  /// Check if can load more notifications.
  bool get canLoadMore => hasMore && !isLoadingMore;

  NotificationState copyWith({
    NotificationLoadStatus? loadStatus,
    bool? isLoadingMore,
    NotificationSubmissionStatus? submissionStatus,
    String? errorMessage,
    NotificationAudience? selectedFilter,
    List<NotificationModel>? notifications,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    NotificationAudience? sentTo,
    List<ClassRoomModel>? selectedClasses,
    List<StudentModel>? selectedStudents,
    String? title,
    String? message,
    File? attachment,
    DateTime? scheduledDateTime,
    List<NotificationAudience>? audiences,
    bool clearAttachment = false,
    bool clearErrorMessage = false,
    bool clearSelectedClasses = false,
    bool clearSelectedStudents = false,
    bool clearScheduledDateTime = false,
  }) {
    return NotificationState(
      loadStatus: loadStatus ?? this.loadStatus,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      sentTo: sentTo ?? this.sentTo,
      selectedClasses: clearSelectedClasses
          ? const []
          : (selectedClasses ?? this.selectedClasses),
      selectedStudents: clearSelectedStudents
          ? const []
          : (selectedStudents ?? this.selectedStudents),
      title: title ?? this.title,
      message: message ?? this.message,
      attachment: clearAttachment ? null : (attachment ?? this.attachment),
      scheduledDateTime: clearScheduledDateTime
          ? null
          : (scheduledDateTime ?? this.scheduledDateTime),
      audiences: audiences ?? this.audiences,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    isLoadingMore,
    submissionStatus,
    errorMessage,
    selectedFilter,
    notifications,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
    sentTo,
    selectedClasses,
    selectedStudents,
    title,
    message,
    attachment?.path,
    scheduledDateTime,
    audiences,
  ];
}
