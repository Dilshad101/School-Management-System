import 'package:equatable/equatable.dart';

/// Model for a school period.
class PeriodModel extends Equatable {
  const PeriodModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.order,
    required this.school,
  });

  final String id;
  final String startTime;
  final String endTime;
  final int order;
  final String school;

  /// Formats time from "HH:mm:ss" to "HH:mmAM/PM"
  String get formattedStartTime => _formatTime(startTime);
  String get formattedEndTime => _formatTime(endTime);

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return time;

      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$hour:$minute$period';
    } catch (_) {
      return time;
    }
  }

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      id: json['id']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      order: _parseInt(json['order']),
      school: json['school']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'order': order,
      'school': school,
    };
  }

  PeriodModel copyWith({
    String? id,
    String? startTime,
    String? endTime,
    int? order,
    String? school,
  }) {
    return PeriodModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      order: order ?? this.order,
      school: school ?? this.school,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [id, startTime, endTime, order, school];
}

/// Response model for paginated period list.
class PeriodListResponse extends Equatable {
  const PeriodListResponse({
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
  final List<PeriodModel> results;

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;

  factory PeriodListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return PeriodListResponse(
      count: data['count'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? 10,
      totalPages: data['total_pages'] as int? ?? 1,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => PeriodModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
