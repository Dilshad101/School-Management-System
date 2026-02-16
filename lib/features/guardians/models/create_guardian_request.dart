import 'package:equatable/equatable.dart';

/// Model for student relation in create guardian request.
class StudentRelation extends Equatable {
  const StudentRelation({required this.studentId, required this.relation});

  final String studentId;
  final String relation;

  Map<String, dynamic> toJson() {
    return {'student': studentId, 'relation': relation};
  }

  @override
  List<Object?> get props => [studentId, relation];
}

/// Request model for creating a new guardian.
class CreateGuardianRequest extends Equatable {
  const CreateGuardianRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.schoolId,
    required this.relations,
    this.isActive = true,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String schoolId;
  final List<StudentRelation> relations;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'profile': {'address': address},
      'school': schoolId,
      'relations': relations.map((r) => r.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    email,
    firstName,
    lastName,
    phone,
    address,
    schoolId,
    relations,
    isActive,
  ];
}

/// Response model when guardian is fetched by email.
class GuardianLookupResponse extends Equatable {
  const GuardianLookupResponse({
    required this.found,
    this.guardian,
    this.message,
  });

  final bool found;
  final GuardianLookupData? guardian;
  final String? message;

  factory GuardianLookupResponse.fromJson(Map<String, dynamic> json) {
    return GuardianLookupResponse(
      found: json['found'] ?? false,
      guardian: json['guardian'] != null
          ? GuardianLookupData.fromJson(
              json['guardian'] as Map<String, dynamic>,
            )
          : null,
      message: json['message'],
    );
  }

  @override
  List<Object?> get props => [found, guardian, message];
}

/// Data model for guardian lookup result.
class GuardianLookupData extends Equatable {
  const GuardianLookupData({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;

  /// Get display name (first + last name).
  String get displayName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim().isEmpty ? '' : '$first $last'.trim();
  }

  factory GuardianLookupData.fromJson(Map<String, dynamic> json) {
    return GuardianLookupData(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      address: json['profile']?['address'],
    );
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName, phone, address];
}

/// Request model for updating an existing guardian.
class UpdateGuardianRequest extends Equatable {
  const UpdateGuardianRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.schoolId,
    required this.relations,
    this.isActive = true,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String schoolId;
  final List<StudentRelation> relations;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'profile': {'address': address},
      'school': schoolId,
      'relations': relations.map((r) => r.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    email,
    firstName,
    lastName,
    phone,
    address,
    schoolId,
    relations,
    isActive,
  ];
}
