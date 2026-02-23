import 'package:equatable/equatable.dart';

/// Enum for notification audience type.
enum NotificationAudience {
  all('All', 'ALL'),
  students('Student', 'STUDENT'),
  employees('Employee', 'EMPLOYEE'),
  guardians('Guardian', 'GUARDIAN');

  const NotificationAudience(this.label, this.apiValue);
  final String label;
  final String apiValue;

  /// Get audience from API value.
  static NotificationAudience fromApiValue(String? value) {
    if (value == null) return NotificationAudience.all;

    return NotificationAudience.values.firstWhere(
      (e) => e.apiValue.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationAudience.all,
    );
  }
}

/// Model for a notification item from API.
class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.createdAt,
    this.attachment,
    this.dateTime,
    this.sent = false,
    this.school,
    this.classes = const [],
    this.students = const [],
  });

  final String id;
  final String title;
  final String message;
  final NotificationAudience notificationType;
  final DateTime createdAt;
  final String? attachment;
  final DateTime? dateTime;
  final bool sent;
  final String? school;
  final List<String> classes;
  final List<String> students;

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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      notificationType: NotificationAudience.fromApiValue(
        json['notification_type']?.toString(),
      ),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      attachment: json['attachment']?.toString(),
      dateTime: json['date_time'] != null
          ? DateTime.tryParse(json['date_time'].toString())
          : null,
      sent: json['sent'] == true,
      school: json['school']?.toString(),
      classes:
          (json['classes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      students:
          (json['students'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'notification_type': notificationType.apiValue,
      'created_at': createdAt.toIso8601String(),
      'attachment': attachment,
      'date_time': dateTime?.toIso8601String(),
      'sent': sent,
      'school': school,
      'classes': classes,
      'students': students,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationAudience? notificationType,
    DateTime? createdAt,
    String? attachment,
    DateTime? dateTime,
    bool? sent,
    String? school,
    List<String>? classes,
    List<String>? students,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      createdAt: createdAt ?? this.createdAt,
      attachment: attachment ?? this.attachment,
      dateTime: dateTime ?? this.dateTime,
      sent: sent ?? this.sent,
      school: school ?? this.school,
      classes: classes ?? this.classes,
      students: students ?? this.students,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    notificationType,
    createdAt,
    attachment,
    dateTime,
    sent,
    school,
    classes,
    students,
  ];
}

/// Response model for paginated notification list.
class NotificationListResponse extends Equatable {
  const NotificationListResponse({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final int page;
  final int pageSize;
  final int totalPages;
  final String? next;
  final String? previous;
  final List<NotificationModel> results;

  /// Whether there are more pages to load.
  bool get hasMore => next != null && next!.isNotEmpty;

  /// Whether this is the first page.
  bool get isFirstPage => previous == null || previous!.isEmpty;

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return NotificationListResponse(
      count: data['count'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? 10,
      totalPages: data['total_pages'] as int? ?? 1,
      next: data['next']?.toString(),
      previous: data['previous']?.toString(),
      results:
          (data['results'] as List<dynamic>?)
              ?.map(
                (e) => NotificationModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Returns an empty response.
  factory NotificationListResponse.empty() {
    return const NotificationListResponse(
      count: 0,
      page: 1,
      pageSize: 10,
      totalPages: 0,
      results: [],
    );
  }

  @override
  List<Object?> get props => [
    count,
    page,
    pageSize,
    totalPages,
    next,
    previous,
    results,
  ];
}
