import 'package:equatable/equatable.dart';

/// Model for school user (teacher) from API.
class SchoolUserModel extends Equatable {
  const SchoolUserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    this.lastName,
    required this.isActive,
    this.rolesDetails = const [],
    this.profile,
  });

  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String? lastName;
  final bool isActive;
  final List<RoleDetail> rolesDetails;
  final UserProfile? profile;

  /// Get the full name of the user.
  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  factory SchoolUserModel.fromJson(Map<String, dynamic> json) {
    return SchoolUserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString(),
      isActive: json['is_active'] ?? true,
      rolesDetails:
          (json['roles_details'] as List<dynamic>?)
              ?.map((e) => RoleDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
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
  ];
}

/// Model for role details.
class RoleDetail extends Equatable {
  const RoleDetail({required this.id, required this.name});

  final String id;
  final String name;

  factory RoleDetail.fromJson(Map<String, dynamic> json) {
    return RoleDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  List<Object?> get props => [id, name];
}

/// Model for user profile.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.user,
    this.profilePic,
    this.dateOfBirth,
    this.address,
    this.bloodGroup,
    this.gender,
  });

  final String id;
  final String user;
  final String? profilePic;
  final String? dateOfBirth;
  final String? address;
  final String? bloodGroup;
  final String? gender;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      profilePic: json['profile_pic']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      address: json['address']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      gender: json['gender']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'profile_pic': profilePic,
      'date_of_birth': dateOfBirth,
      'address': address,
      'blood_group': bloodGroup,
      'gender': gender,
    };
  }

  @override
  List<Object?> get props => [
    id,
    user,
    profilePic,
    dateOfBirth,
    address,
    bloodGroup,
    gender,
  ];
}

/// Model for paginated school user response.
class SchoolUserListResponse extends Equatable {
  const SchoolUserListResponse({
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
  final List<SchoolUserModel> results;

  factory SchoolUserListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SchoolUserListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => SchoolUserModel.fromJson(e as Map<String, dynamic>))
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
