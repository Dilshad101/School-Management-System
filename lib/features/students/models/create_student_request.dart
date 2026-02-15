import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';

/// Request model for creating/updating a student.
class CreateStudentRequest {
  CreateStudentRequest({
    required this.email,
    this.phone,
    required this.firstName,
    this.lastName,
    this.profilePic,
    this.dateOfBirth,
    this.address,
    this.gender,
    this.bloodGroup,
    this.documents = const [],
    required this.school,
    this.rollNo,
    this.classroomId,
    this.academicYearId,
  });

  final String email;
  final String? phone;
  final String firstName;
  final String? lastName;
  final File? profilePic;
  final DateTime? dateOfBirth;
  final String? address;
  final String? gender;
  final String? bloodGroup;
  final List<DocumentRequest> documents;
  final String school;
  final String? rollNo;
  final int? classroomId;
  final int? academicYearId;

  /// Converts the request to JSON format for API submission.
  Future<Map<String, dynamic>> toJson() async {
    final profile = <String, dynamic>{};

    if (profilePic != null) {
      profile['profile_pic'] = await _fileToBase64DataUri(profilePic!);
    }
    if (dateOfBirth != null) {
      profile['date_of_birth'] = _formatDate(dateOfBirth!);
    }
    if (address != null && address!.isNotEmpty) {
      profile['address'] = address;
    }
    if (gender != null && gender!.isNotEmpty) {
      profile['gender'] = gender;
    }
    if (bloodGroup != null && bloodGroup!.isNotEmpty) {
      profile['blood_group'] = bloodGroup;
    }

    final List<Map<String, dynamic>> documentsList = [];
    for (final doc in documents) {
      if (doc.file != null) {
        documentsList.add({
          'document_name': doc.name,
          'document_file': await _fileToBase64DataUri(doc.file!),
        });
      }
    }

    final Map<String, dynamic> studentEnrolment = {};
    if (rollNo != null && rollNo!.isNotEmpty) {
      studentEnrolment['roll_no'] = rollNo;
    }
    if (classroomId != null) {
      studentEnrolment['classroom'] = classroomId;
    }
    if (academicYearId != null) {
      studentEnrolment['academic_year'] = academicYearId;
    }

    final json = <String, dynamic>{
      'email': email,
      'first_name': firstName,
      'school': school,
    };

    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }
    if (lastName != null && lastName!.isNotEmpty) {
      json['last_name'] = lastName;
    }
    if (profile.isNotEmpty) {
      json['profile'] = profile;
    }
    if (documentsList.isNotEmpty) {
      json['documents'] = documentsList;
    }
    if (studentEnrolment.isNotEmpty) {
      json['student_enrolment'] = studentEnrolment;
    }

    return json;
  }

  /// Converts a file to base64 data URI format.
  static Future<String> _fileToBase64DataUri(File file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    return 'data:$mimeType;base64,$base64String';
  }

  /// Formats date to YYYY-MM-DD format.
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Model for document in create student request.
class DocumentRequest {
  const DocumentRequest({required this.name, this.file});

  final String name;
  final File? file;
}

/// Request model for updating a student.
class UpdateStudentRequest {
  UpdateStudentRequest({
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.profilePic,
    this.profilePicUrl,
    this.dateOfBirth,
    this.address,
    this.gender,
    this.bloodGroup,
    this.documents = const [],
    this.rollNo,
    this.classroomId,
    this.academicYearId,
  });

  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final File? profilePic;
  final String? profilePicUrl;
  final DateTime? dateOfBirth;
  final String? address;
  final String? gender;
  final String? bloodGroup;
  final List<DocumentRequest> documents;
  final String? rollNo;
  final int? classroomId;
  final int? academicYearId;

  /// Converts the request to JSON format for API submission.
  Future<Map<String, dynamic>> toJson() async {
    final json = <String, dynamic>{};
    final profile = <String, dynamic>{};

    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }
    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }
    if (firstName != null && firstName!.isNotEmpty) {
      json['first_name'] = firstName;
    }
    if (lastName != null) {
      json['last_name'] = lastName;
    }

    // Only include profile_pic if a new file is selected (not just URL)
    if (profilePic != null) {
      profile['profile_pic'] = await CreateStudentRequest._fileToBase64DataUri(
        profilePic!,
      );
    }
    if (dateOfBirth != null) {
      profile['date_of_birth'] = CreateStudentRequest._formatDate(dateOfBirth!);
    }
    if (address != null) {
      profile['address'] = address;
    }
    if (gender != null) {
      profile['gender'] = gender;
    }
    if (bloodGroup != null) {
      profile['blood_group'] = bloodGroup;
    }

    if (profile.isNotEmpty) {
      json['profile'] = profile;
    }

    // Handle documents - only include new documents with files
    final List<Map<String, dynamic>> documentsList = [];
    for (final doc in documents) {
      if (doc.file != null) {
        documentsList.add({
          'document_name': doc.name,
          'document_file': await CreateStudentRequest._fileToBase64DataUri(
            doc.file!,
          ),
        });
      }
    }
    if (documentsList.isNotEmpty) {
      json['documents'] = documentsList;
    }

    // Student enrolment
    final Map<String, dynamic> studentEnrolment = {};
    if (rollNo != null && rollNo!.isNotEmpty) {
      studentEnrolment['roll_no'] = rollNo;
    }
    if (classroomId != null) {
      studentEnrolment['classroom'] = classroomId;
    }
    if (academicYearId != null) {
      studentEnrolment['academic_year'] = academicYearId;
    }
    if (studentEnrolment.isNotEmpty) {
      json['student_enrolment'] = studentEnrolment;
    }

    return json;
  }
}
