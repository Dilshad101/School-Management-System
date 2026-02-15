import 'package:equatable/equatable.dart';

import 'academic_year_model.dart';

/// Model for classroom.
class ClassRoomModel extends Equatable {
  const ClassRoomModel({
    required this.id,
    required this.name,
    this.code,
    this.meta,
    this.school,
    this.academicYear,
    this.classTeacher,
    this.academicYearDetails,
  });

  final int id;
  final String name;
  final String? code;
  final Map<String, dynamic>? meta;
  final String? school;
  final int? academicYear;
  final int? classTeacher;
  final AcademicYearModel? academicYearDetails;

  factory ClassRoomModel.fromJson(Map<String, dynamic> json) {
    return ClassRoomModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
      meta: json['meta'] as Map<String, dynamic>?,
      school: json['school'],
      academicYear: json['academic_year'],
      classTeacher: json['class_teacher'],
      academicYearDetails: json['academic_year_details'] != null
          ? AcademicYearModel.fromJson(
              json['academic_year_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'meta': meta,
      'school': school,
      'academic_year': academicYear,
      'class_teacher': classTeacher,
      'academic_year_details': academicYearDetails?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    meta,
    school,
    academicYear,
    classTeacher,
    academicYearDetails,
  ];
}

/// Model for paginated classroom response.
class ClassRoomListResponse extends Equatable {
  const ClassRoomListResponse({
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
  final List<ClassRoomModel> results;

  factory ClassRoomListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return ClassRoomListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => ClassRoomModel.fromJson(e as Map<String, dynamic>))
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
