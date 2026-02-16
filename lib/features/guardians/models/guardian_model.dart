import 'package:equatable/equatable.dart';

/// Model for role details in guardian.
class GuardianRoleDetail extends Equatable {
  const GuardianRoleDetail({
    required this.roleId,
    required this.roleName,
    this.schoolId,
  });

  final String roleId;
  final String roleName;
  final String? schoolId;

  factory GuardianRoleDetail.fromJson(Map<String, dynamic> json) {
    return GuardianRoleDetail(
      roleId: json['role__id']?.toString() ?? '',
      roleName: json['role__name']?.toString() ?? '',
      schoolId: json['user_school__school_id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [roleId, roleName, schoolId];
}

/// Model for guardian profile.
class GuardianProfile extends Equatable {
  const GuardianProfile({
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

  final String id;
  final String user;
  final String? profilePic;
  final String? dateOfBirth;
  final String? address;
  final String? agentId;
  final String? bloodGroup;
  final String? gender;
  final String? createdAt;
  final String? updatedAt;

  factory GuardianProfile.fromJson(Map<String, dynamic> json) {
    return GuardianProfile(
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

/// Model for relation details (linked students).
class RelationDetail extends Equatable {
  const RelationDetail({
    required this.id,
    this.studentFirstName,
    this.studentLastName,
    this.relation,
    this.profilePic,
    this.classroomName,
  });

  final String id;
  final String? studentFirstName;
  final String? studentLastName;
  final String? relation;
  final String? profilePic;
  final String? classroomName;

  /// Get student display name.
  String get studentName {
    final first = studentFirstName ?? '';
    final last = studentLastName ?? '';
    return '$first $last'.trim().isEmpty ? 'Unknown' : '$first $last'.trim();
  }

  factory RelationDetail.fromJson(Map<String, dynamic> json) {
    return RelationDetail(
      id: json['id']?.toString() ?? '',
      studentFirstName: json['student_first_name'],
      studentLastName: json['student_last_name'],
      relation: json['relation'],
      profilePic: json['profile_pic'],
      classroomName: json['classroom_name'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentFirstName,
    studentLastName,
    relation,
    profilePic,
    classroomName,
  ];
}

/// Model for linked student information (used in Add Guardian).
class LinkedStudentModel extends Equatable {
  const LinkedStudentModel({
    required this.id,
    required this.name,
    required this.className,
    this.division = '',
    this.studentId = '',
    this.profilePic,
    this.relation = '',
  });

  final String id;
  final String name;
  final String className;
  final String division;
  final String studentId;
  final String? profilePic;
  final String relation;

  /// Display string combining class and division.
  String get classInfo =>
      division.isNotEmpty ? '$className $division' : className;

  /// Display string for ID.
  String get displayId => studentId.isNotEmpty ? 'ID $studentId' : '';

  factory LinkedStudentModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure from student search API
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';
    final name = '$firstName $lastName'.trim();

    // Get classroom name from various possible locations
    final classroomName =
        json['classroom_name'] ?? json['class_name'] ?? json['class'] ?? '';

    // Get profile pic from nested profile object or direct field
    final profilePic = json['profile']?['profile_pic'] ?? json['profile_pic'];

    return LinkedStudentModel(
      id: json['id']?.toString() ?? '',
      name: name.isEmpty ? (json['name'] ?? '') : name,
      className: classroomName,
      division: json['division'] ?? '',
      studentId: json['id']?.toString() ?? '',
      profilePic: profilePic,
    );
  }

  /// Create from RelationDetail
  factory LinkedStudentModel.fromRelation(RelationDetail relation) {
    return LinkedStudentModel(
      id: relation.id,
      name: relation.studentName,
      className: relation.classroomName ?? '',
      profilePic: relation.profilePic,
      relation: relation.relation ?? '',
    );
  }

  /// Create a copy with relation
  LinkedStudentModel copyWith({
    String? id,
    String? name,
    String? className,
    String? division,
    String? studentId,
    String? profilePic,
    String? relation,
  }) {
    return LinkedStudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      className: className ?? this.className,
      division: division ?? this.division,
      studentId: studentId ?? this.studentId,
      profilePic: profilePic ?? this.profilePic,
      relation: relation ?? this.relation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'class_name': className,
      'division': division,
      'student_id': studentId,
      'profile_pic': profilePic,
      'relation': relation,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    className,
    division,
    studentId,
    profilePic,
    relation,
  ];
}

/// Model for a guardian.
class GuardianModel extends Equatable {
  const GuardianModel({
    required this.id,
    required this.email,
    this.phone,
    this.firstName,
    this.lastName,
    required this.isActive,
    this.isPlatformAdmin = false,
    this.rolesDetails = const [],
    this.profile,
    this.relationsDetails = const [],
  });

  final String id;
  final String email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final bool isPlatformAdmin;
  final List<GuardianRoleDetail> rolesDetails;
  final GuardianProfile? profile;
  final List<RelationDetail> relationsDetails;

  /// Get display name (first + last name).
  String get displayName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim().isEmpty ? 'Unknown' : '$first $last'.trim();
  }

  /// Get address from profile.
  String? get address => profile?.address;

  /// Get profile picture from profile.
  String? get profilePic => profile?.profilePic;

  /// Get primary relation (first linked student's relation).
  String? get primaryRelation =>
      relationsDetails.isNotEmpty ? relationsDetails.first.relation : null;

  /// Get number of linked students.
  int get linkedStudentsCount => relationsDetails.length;

  /// Get linked students as LinkedStudentModel list.
  List<LinkedStudentModel> get linkedStudents =>
      relationsDetails.map((r) => LinkedStudentModel.fromRelation(r)).toList();

  factory GuardianModel.fromJson(Map<String, dynamic> json) {
    return GuardianModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      isActive: json['is_active'] ?? true,
      isPlatformAdmin: json['is_platform_admin'] ?? false,
      rolesDetails:
          (json['roles_details'] as List<dynamic>?)
              ?.map(
                (e) => GuardianRoleDetail.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      profile: json['profile'] != null
          ? GuardianProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      relationsDetails:
          (json['relations_details'] as List<dynamic>?)
              ?.map((e) => RelationDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'is_platform_admin': isPlatformAdmin,
    };
  }

  GuardianModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    bool? isActive,
    bool? isPlatformAdmin,
    List<GuardianRoleDetail>? rolesDetails,
    GuardianProfile? profile,
    List<RelationDetail>? relationsDetails,
  }) {
    return GuardianModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      isPlatformAdmin: isPlatformAdmin ?? this.isPlatformAdmin,
      rolesDetails: rolesDetails ?? this.rolesDetails,
      profile: profile ?? this.profile,
      relationsDetails: relationsDetails ?? this.relationsDetails,
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
    isPlatformAdmin,
    rolesDetails,
    profile,
    relationsDetails,
  ];
}

/// Response model for paginated guardian list.
class GuardianListResponse extends Equatable {
  const GuardianListResponse({
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
  final List<GuardianModel> results;

  factory GuardianListResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure: { "success": true, "data": { ... } }
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return GuardianListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => GuardianModel.fromJson(e as Map<String, dynamic>))
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
