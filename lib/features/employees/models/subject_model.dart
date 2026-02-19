import 'package:equatable/equatable.dart';

/// Model representing a subject from the API.
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
      code: json['code'],
      isLab: json['is_lab'] ?? false,
      school: json['school'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_lab': isLab,
      'school': school,
    };
  }

  @override
  List<Object?> get props => [id, name, code, isLab, school];
}

/// Model for paginated subjects response.
class SubjectsListResponse extends Equatable {
  const SubjectsListResponse({
    required this.count,
    required this.hasNext,
    required this.hasPrevious,
    required this.results,
  });

  final int count;
  final bool hasNext;
  final bool hasPrevious;
  final List<SubjectModel> results;

  factory SubjectsListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SubjectsListResponse(
      count: data['count'] ?? 0,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [count, hasNext, hasPrevious, results];
}
