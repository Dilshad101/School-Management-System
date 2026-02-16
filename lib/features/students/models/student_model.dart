import 'package:equatable/equatable.dart';

/// Model for student role details.
class RoleDetailModel extends Equatable {
  const RoleDetailModel({required this.roleId, required this.roleName});

  final String roleId;
  final String roleName;

  factory RoleDetailModel.fromJson(Map<String, dynamic> json) {
    return RoleDetailModel(
      roleId: json['role__id'] ?? '',
      roleName: json['role__name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [roleId, roleName];
}

/// Model for student profile.
class StudentProfileModel extends Equatable {
  const StudentProfileModel({
    required this.id,
    required this.user,
    this.profilePic,
    this.dateOfBirth,
    this.address,
    this.agentId,
    this.bloodGroup,
    this.gender,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? user;
  final String? profilePic;
  final String? dateOfBirth;
  final String? address;
  final String? agentId;
  final String? bloodGroup;
  final String? gender;
  final String? createdAt;
  final String? updatedAt;

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      profilePic: json['profile_pic'],
      dateOfBirth: json['date_of_birth'],
      address: json['address'],
      agentId: json['agent_id'],
      bloodGroup: json['blood_group'],
      gender: json['gender'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    user,
    profilePic,
    dateOfBirth,
    address,
    agentId,
    bloodGroup,
    gender,
    createdAt,
    updatedAt,
  ];
}

/// Model for a student.
class StudentModel extends Equatable {
  const StudentModel({
    required this.id,
    required this.email,
    this.phone,
    this.firstName,
    this.lastName,
    required this.isActive,
    this.rolesDetails = const [],
    this.profile,
    this.documents = const [],
  });

  final String? id;
  final String email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final List<RoleDetailModel> rolesDetails;
  final StudentProfileModel? profile;
  final List<dynamic> documents;

  /// Get the student's full name.
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    final name = '$first $last'.trim();
    return name.isEmpty ? email : name;
  }

  /// Get profile picture URL.
  String? get profilePicUrl => profile?.profilePic;

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      isActive: json['is_active'] ?? true,
      rolesDetails:
          (json['roles_details'] as List<dynamic>?)
              ?.map((e) => RoleDetailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      profile: json['profile'] != null
          ? StudentProfileModel.fromJson(
              json['profile'] as Map<String, dynamic>,
            )
          : null,
      documents: json['documents'] as List<dynamic>? ?? [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    firstName,
    lastName,
    isActive,
    rolesDetails,
    profile,
    documents,
  ];
}

/// Model for paginated student response.
class StudentListResponse extends Equatable {
  const StudentListResponse({
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
  final List<StudentModel> results;

  factory StudentListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return StudentListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
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
