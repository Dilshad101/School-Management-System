import 'package:equatable/equatable.dart';

/// Enum representing fee frequency.
enum FeeFrequency {
  monthly('monthly', 'Monthly'),
  yearly('yearly', 'Yearly'),
  semester('semester', 'Semester'),
  oneTime('one_time', 'One Time');

  const FeeFrequency(this.value, this.displayName);

  final String value;
  final String displayName;

  static FeeFrequency fromString(String? value) {
    return FeeFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeeFrequency.monthly,
    );
  }
}

/// Model representing a fee component.
class FeeComponentModel extends Equatable {
  const FeeComponentModel({
    required this.id,
    required this.name,
    required this.frequency,
    required this.isOptional,
    this.school,
  });

  final String id;
  final String name;
  final FeeFrequency frequency;
  final bool isOptional;
  final String? school;

  /// Returns "Mandatory" or "Optional" based on isOptional
  String get typeDisplayName => isOptional ? 'Optional' : 'Mandatory';

  factory FeeComponentModel.fromJson(Map<String, dynamic> json) {
    return FeeComponentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      frequency: FeeFrequency.fromString(json['frequency']?.toString()),
      isOptional: json['is_optional'] ?? false,
      school: json['school']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'frequency': frequency.value,
      'is_optional': isOptional,
      'school': school,
    };
  }

  FeeComponentModel copyWith({
    String? id,
    String? name,
    FeeFrequency? frequency,
    bool? isOptional,
    String? school,
  }) {
    return FeeComponentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      isOptional: isOptional ?? this.isOptional,
      school: school ?? this.school,
    );
  }

  @override
  List<Object?> get props => [id, name, frequency, isOptional, school];
}

/// Response model for paginated fee component list.
class FeeComponentListResponse extends Equatable {
  const FeeComponentListResponse({
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
  final List<FeeComponentModel> results;

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;

  factory FeeComponentListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return FeeComponentListResponse(
      count: data['count'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? 10,
      totalPages: data['total_pages'] as int? ?? 1,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
      results:
          (data['results'] as List<dynamic>?)
              ?.map(
                (e) => FeeComponentModel.fromJson(e as Map<String, dynamic>),
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
