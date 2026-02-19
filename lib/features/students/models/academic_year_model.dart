import 'package:equatable/equatable.dart';

/// Model for academic year.
class AcademicYearModel extends Equatable {
  const AcademicYearModel({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.school,
  });

  final String? id;
  final String name;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? school;

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      isCurrent: json['is_current'] ?? false,
      school: json['school'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
      'is_current': isCurrent,
      'school': school,
    };
  }

  @override
  List<Object?> get props => [id, name, startDate, endDate, isCurrent, school];
}

/// Model for paginated academic year response.
class AcademicYearListResponse extends Equatable {
  const AcademicYearListResponse({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.results,
  });

  final int count;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final List<AcademicYearModel> results;

  factory AcademicYearListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AcademicYearListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
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
    hasNext,
    hasPrevious,
    results,
  ];
}
