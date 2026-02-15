import 'package:equatable/equatable.dart';

/// Model for student document from API response.
class StudentDocumentModel extends Equatable {
  const StudentDocumentModel({
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

  factory StudentDocumentModel.fromJson(Map<String, dynamic> json) {
    return StudentDocumentModel(
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
