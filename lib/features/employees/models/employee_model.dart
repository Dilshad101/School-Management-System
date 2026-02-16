import 'package:equatable/equatable.dart';

/// Model for employee role details.
class EmployeeRoleModel extends Equatable {
  const EmployeeRoleModel({required this.roleId, required this.roleName});

  final String roleId;
  final String roleName;

  factory EmployeeRoleModel.fromJson(Map<String, dynamic> json) {
    return EmployeeRoleModel(
      roleId: json['role__id'] ?? '',
      roleName: json['role__name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'role__id': roleId, 'role__name': roleName};
  }

  @override
  List<Object?> get props => [roleId, roleName];
}

/// Model for employee profile.
class EmployeeProfileModel extends Equatable {
  const EmployeeProfileModel({
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

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'profile_pic': profilePic,
      'date_of_birth': dateOfBirth,
      'address': address,
      'agent_id': agentId,
      'blood_group': bloodGroup,
      'gender': gender,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
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

/// Model for employee document.
class EmployeeDocumentApiModel extends Equatable {
  const EmployeeDocumentApiModel({
    required this.id,
    required this.user,
    this.documentFile,
    this.documentName,
    this.documentNumber,
    this.isVerified = false,
    this.uploadedAt,
  });

  final int id;
  final int user;
  final String? documentFile;
  final String? documentName;
  final String? documentNumber;
  final bool isVerified;
  final String? uploadedAt;

  factory EmployeeDocumentApiModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDocumentApiModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      documentFile: json['document_file'],
      documentName: json['document_name'],
      documentNumber: json['document_number'],
      isVerified: json['is_verified'] ?? false,
      uploadedAt: json['uploaded_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'document_file': documentFile,
      'document_name': documentName,
      'document_number': documentNumber,
      'is_verified': isVerified,
      'uploaded_at': uploadedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    user,
    documentFile,
    documentName,
    documentNumber,
    isVerified,
    uploadedAt,
  ];
}

/// Model for an employee/school user.
class EmployeeModel extends Equatable {
  const EmployeeModel({
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

  final String id;
  final String email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final List<EmployeeRoleModel> rolesDetails;
  final EmployeeProfileModel? profile;
  final List<EmployeeDocumentApiModel> documents;

  /// Get the employee's full name.
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    final name = '$first $last'.trim();
    return name.isEmpty ? email : name;
  }

  /// Get profile picture URL.
  String? get profilePicUrl => profile?.profilePic;

  /// Get primary role name.
  String? get primaryRole =>
      rolesDetails.isNotEmpty ? rolesDetails.first.roleName : null;

  /// Get employee ID for display.
  String get displayId => 'ID $id';

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      isActive: json['is_active'] ?? true,
      rolesDetails:
          (json['roles_details'] as List<dynamic>?)
              ?.map(
                (e) => EmployeeRoleModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      profile: json['profile'] != null
          ? EmployeeProfileModel.fromJson(
              json['profile'] as Map<String, dynamic>,
            )
          : null,
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map(
                (e) => EmployeeDocumentApiModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
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
      'roles_details': rolesDetails.map((e) => e.toJson()).toList(),
      'profile': profile?.toJson(),
      'documents': documents.map((e) => e.toJson()).toList(),
    };
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

/// Model for paginated employee response.
class EmployeeListResponse extends Equatable {
  const EmployeeListResponse({
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
  final List<EmployeeModel> results;

  factory EmployeeListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return EmployeeListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
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
