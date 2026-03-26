import 'package:equatable/equatable.dart';

/// Model representing a fee structure item (component with amount).
class FeeStructureItemModel extends Equatable {
  const FeeStructureItemModel({
    required this.id,
    required this.componentId,
    required this.componentName,
    required this.totalAmount,
    this.feeStructureId,
  });

  final String id;
  final String componentId;
  final String componentName;
  final String totalAmount;
  final String? feeStructureId;

  factory FeeStructureItemModel.fromJson(Map<String, dynamic> json) {
    return FeeStructureItemModel(
      id: json['id']?.toString() ?? '',
      componentId: json['component']?.toString() ?? '',
      componentName: json['component_name']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0',
      feeStructureId: json['fee_structure']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'component': componentId, 'total_amount': totalAmount};
  }

  @override
  List<Object?> get props => [
    id,
    componentId,
    componentName,
    totalAmount,
    feeStructureId,
  ];
}

/// Model representing classroom details in fee structure.
class ClassroomDetailsModel extends Equatable {
  const ClassroomDetailsModel({required this.id, required this.name});

  final String id;
  final String name;

  factory ClassroomDetailsModel.fromJson(Map<String, dynamic> json) {
    return ClassroomDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Model representing academic year details in fee structure.
class AcademicYearDetailsModel extends Equatable {
  const AcademicYearDetailsModel({required this.id, required this.name});

  final String id;
  final String name;

  factory AcademicYearDetailsModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Model representing a fee structure.
class FeeStructureModel extends Equatable {
  const FeeStructureModel({
    required this.id,
    required this.name,
    required this.items,
    required this.classroomDetails,
    required this.academicYearDetails,
    required this.totalAmount,
    required this.isActive,
    this.school,
    this.academicYearId,
    this.classroomId,
  });

  final String id;
  final String name;
  final List<FeeStructureItemModel> items;
  final ClassroomDetailsModel classroomDetails;
  final AcademicYearDetailsModel academicYearDetails;
  final double totalAmount;
  final bool isActive;
  final String? school;
  final String? academicYearId;
  final String? classroomId;

  /// Display string for assigned class
  String get assignedClassName => classroomDetails.name;

  /// Display string for academic year
  String get academicYearName => academicYearDetails.name;

  /// Comma-separated list of fee component names
  String get feeComponentNames {
    if (items.isEmpty) return 'No components';
    return items.map((e) => e.componentName).join(', ');
  }

  factory FeeStructureModel.fromJson(Map<String, dynamic> json) {
    final itemsList =
        (json['items'] as List<dynamic>?)
            ?.map(
              (e) => FeeStructureItemModel.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return FeeStructureModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      items: itemsList,
      classroomDetails: ClassroomDetailsModel.fromJson(
        json['classroom_details'] as Map<String, dynamic>? ?? {},
      ),
      academicYearDetails: AcademicYearDetailsModel.fromJson(
        json['academic_year_details'] as Map<String, dynamic>? ?? {},
      ),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? true,
      school: json['school']?.toString(),
      academicYearId: json['academic_year']?.toString(),
      classroomId: json['classroom']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'classroom': classroomId ?? classroomDetails.id,
      'academic_year': academicYearId ?? academicYearDetails.id,
      'items': items.map((e) => e.toJson()).toList(),
      'school': school,
    };
  }

  FeeStructureModel copyWith({
    String? id,
    String? name,
    List<FeeStructureItemModel>? items,
    ClassroomDetailsModel? classroomDetails,
    AcademicYearDetailsModel? academicYearDetails,
    double? totalAmount,
    bool? isActive,
    String? school,
    String? academicYearId,
    String? classroomId,
  }) {
    return FeeStructureModel(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      classroomDetails: classroomDetails ?? this.classroomDetails,
      academicYearDetails: academicYearDetails ?? this.academicYearDetails,
      totalAmount: totalAmount ?? this.totalAmount,
      isActive: isActive ?? this.isActive,
      school: school ?? this.school,
      academicYearId: academicYearId ?? this.academicYearId,
      classroomId: classroomId ?? this.classroomId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    items,
    classroomDetails,
    academicYearDetails,
    totalAmount,
    isActive,
    school,
    academicYearId,
    classroomId,
  ];
}

/// Response model for paginated fee structure list.
class FeeStructureListResponse extends Equatable {
  const FeeStructureListResponse({
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
  final List<FeeStructureModel> results;

  bool get hasMore => next != null;

  factory FeeStructureListResponse.fromJson(Map<String, dynamic> json) {
    final resultsList =
        (json['results'] as List<dynamic>?)
            ?.map((e) => FeeStructureModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return FeeStructureListResponse(
      count: json['count'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
      next: json['next'],
      previous: json['previous'],
      results: resultsList,
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
