import 'package:equatable/equatable.dart';

/// Model representing a subject.
class SubjectModel extends Equatable {
  const SubjectModel({
    required this.id,
    required this.name,
    this.code,
    this.isLab = false,
    this.school,
  });

  final String id;
  final String name;
  final String? code;
  final bool isLab;
  final String? school;

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      isLab: json['is_lab'] ?? false,
      school: json['school']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'code': code, 'is_lab': isLab, 'school': school};
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? code,
    bool? isLab,
    String? school,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      isLab: isLab ?? this.isLab,
      school: school ?? this.school,
    );
  }

  @override
  List<Object?> get props => [id, name, code, isLab, school];
}

/// Response model for paginated subject list.
class SubjectListResponse extends Equatable {
  const SubjectListResponse({
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
  final List<SubjectModel> results;

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;

  factory SubjectListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return SubjectListResponse(
      count: data['count'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? 10,
      totalPages: data['total_pages'] as int? ?? 1,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
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
