import 'package:equatable/equatable.dart';

/// Model for academic year details.
class AcademicYearModel extends Equatable {
  const AcademicYearModel({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.school,
  });

  final String id;
  final String name;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String school;

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      isCurrent: json['is_current'] ?? false,
      school: json['school']?.toString() ?? '',
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

/// Model for class teacher details.
class ClassTeacherModel extends Equatable {
  const ClassTeacherModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;

  factory ClassTeacherModel.fromJson(Map<String, dynamic> json) {
    return ClassTeacherModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'phone': phone};
  }

  @override
  List<Object?> get props => [id, name, email, phone];
}

/// Model for classroom.
class ClassroomModel extends Equatable {
  const ClassroomModel({
    required this.id,
    required this.name,
    required this.code,
    required this.school,
    required this.academicYear,
    required this.studentCount,
    this.academicYearDetails,
    this.classTeacher,
    this.classTeacherDetails,
  });

  final String id;
  final String name;
  final String code;
  final String school;
  final String academicYear;
  final int studentCount;
  final AcademicYearModel? academicYearDetails;
  final String? classTeacher;
  final ClassTeacherModel? classTeacherDetails;

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      school: json['school']?.toString() ?? '',
      academicYear: json['academic_year']?.toString() ?? '',
      studentCount: json['student_count'] ?? 0,
      academicYearDetails: json['academic_year_details'] != null
          ? AcademicYearModel.fromJson(
              json['academic_year_details'] as Map<String, dynamic>,
            )
          : null,
      classTeacher: json['class_teacher'],
      classTeacherDetails: json['class_teacher_details'] != null
          ? ClassTeacherModel.fromJson(
              json['class_teacher_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'school': school,
      'academic_year': academicYear,
      'student_count': studentCount,
      'academic_year_details': academicYearDetails?.toJson(),
      'class_teacher': classTeacher,
      'class_teacher_details': classTeacherDetails?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    school,
    academicYear,
    studentCount,
    academicYearDetails,
    classTeacher,
    classTeacherDetails,
  ];
}

/// Model for paginated classroom response.
class ClassroomListResponse extends Equatable {
  const ClassroomListResponse({
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
  final List<ClassroomModel> results;

  factory ClassroomListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return ClassroomListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => ClassroomModel.fromJson(e as Map<String, dynamic>))
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
