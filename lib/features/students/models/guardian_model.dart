import 'package:equatable/equatable.dart';

/// Model for guardian/relation details from student API.
class GuardianModel extends Equatable {
  const GuardianModel({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.relation,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? relation;

  /// Get the guardian's full name.
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    final name = '$first $last'.trim();
    return name.isEmpty ? 'Unknown' : name;
  }

  factory GuardianModel.fromJson(Map<String, dynamic> json) {
    return GuardianModel(
      firstName: json['guardian_first_name']?.toString(),
      lastName: json['guardian_last_name']?.toString(),
      email: json['guardian_email']?.toString(),
      phone: json['guardian_phone']?.toString(),
      relation: json['relation']?.toString(),
    );
  }

  @override
  List<Object?> get props => [firstName, lastName, email, phone, relation];
}
