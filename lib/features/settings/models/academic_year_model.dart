import 'package:equatable/equatable.dart';

/// Model representing an academic year.
class AcademicYearModel extends Equatable {
  const AcademicYearModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.school,
  });

  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final String? school;

  /// Formats date from "yyyy-MM-dd" to "dd/MM/yyyy" for display
  String get formattedStartDate => _formatDate(startDate);
  String get formattedEndDate => _formatDate(endDate);

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (_) {}
    return date;
  }

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      isCurrent: json['is_current'] ?? false,
      school: json['school']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
      'school': school,
    };
  }

  AcademicYearModel copyWith({
    String? id,
    String? name,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    String? school,
  }) {
    return AcademicYearModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      school: school ?? this.school,
    );
  }

  @override
  List<Object?> get props => [id, name, startDate, endDate, isCurrent, school];
}

/// Response model for paginated academic year list.
class AcademicYearListResponse extends Equatable {
  const AcademicYearListResponse({
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
  final List<AcademicYearModel> results;

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;

  factory AcademicYearListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return AcademicYearListResponse(
      count: data['count'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? 10,
      totalPages: data['total_pages'] as int? ?? 1,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
      results:
          (data['results'] as List<dynamic>?)
              ?.map(
                (e) => AcademicYearModel.fromJson(e as Map<String, dynamic>),
              )
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
