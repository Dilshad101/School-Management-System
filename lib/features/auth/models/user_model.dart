import 'package:equatable/equatable.dart';

/// Model for user role in a school.
class UserSchoolRole extends Equatable {
  const UserSchoolRole({
    required this.id,
    required this.user,
    required this.school,
    required this.roles,
    required this.status,
    this.joinedAt,
  });

  final int id;
  final int user;
  final String school;
  final List<String> roles;
  final String status;
  final DateTime? joinedAt;

  factory UserSchoolRole.fromJson(Map<String, dynamic> json) {
    return UserSchoolRole(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      school: json['school'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      status: json['status'] ?? '',
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'])
          : null,
    );
  }

  @override
  List<Object?> get props => [id, user, school, roles, status, joinedAt];
}

/// Model for user details.
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.firstName,
    this.lastName,
    required this.isPlatformAdmin,
    required this.isActive,
    required this.isSuperuser,
    this.roles = const [],
    this.permissions = const [],
    this.schools = const [],
  });

  final int id;
  final String email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final bool isPlatformAdmin;
  final bool isActive;
  final bool isSuperuser;
  final List<UserSchoolRole> roles;
  final List<String> permissions;
  final List<UserSchoolRole> schools;

  /// Get the user's full name.
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim().isEmpty ? email : '$first $last'.trim();
  }

  /// Get first school ID if available.
  String? get primarySchoolId {
    if (schools.isNotEmpty) {
      return schools.first.school;
    }
    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return UserModel(
      id: data['id'] ?? 0,
      email: data['email'] ?? '',
      phone: data['phone'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      isPlatformAdmin: data['is_platform_admin'] ?? false,
      isActive: data['is_active'] ?? true,
      isSuperuser: data['is_superuser'] ?? false,
      roles:
          (data['role'] as List<dynamic>?)
              ?.map((e) => UserSchoolRole.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      permissions: List<String>.from(data['permission'] ?? []),
      schools:
          (data['schools'] as List<dynamic>?)
              ?.map((e) => UserSchoolRole.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    firstName,
    lastName,
    isPlatformAdmin,
    isActive,
    isSuperuser,
    roles,
    permissions,
    schools,
  ];
}
