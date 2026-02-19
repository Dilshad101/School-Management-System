import 'package:equatable/equatable.dart';

/// Model representing a role from the API.
class RoleModel extends Equatable {
  const RoleModel({
    required this.id,
    required this.name,
    this.scope,
    this.schoolId,
    this.permissions = const [],
    this.isActive = true,
    this.permissionDetails = const [],
  });

  final String id;
  final String name;
  final String? scope;
  final String? schoolId;
  final List<String> permissions;
  final bool isActive;
  final List<dynamic> permissionDetails;

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      scope: json['scope'],
      schoolId: json['school_id'],
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['is_active'] ?? true,
      permissionDetails: json['permission_details'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scope': scope,
      'school_id': schoolId,
      'permissions': permissions,
      'is_active': isActive,
      'permission_details': permissionDetails,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    scope,
    schoolId,
    permissions,
    isActive,
    permissionDetails,
  ];
}

/// Model for paginated roles response.
class RolesListResponse extends Equatable {
  const RolesListResponse({
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
  final List<RoleModel> results;

  factory RolesListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return RolesListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 100,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
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
