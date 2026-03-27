import 'package:equatable/equatable.dart';

/// Model for document details from student API.
class DocumentModel extends Equatable {
  const DocumentModel({
    required this.id,
    this.userId,
    this.documentFile,
    this.documentName,
    this.documentNumber,
    this.isVerified = false,
    this.uploadedAt,
  });

  final String id;
  final String? userId;
  final String? documentFile;
  final String? documentName;
  final String? documentNumber;
  final bool isVerified;
  final String? uploadedAt;

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString() ?? '',
      userId: json['user']?.toString(),
      documentFile: json['document_file']?.toString(),
      documentName: json['document_name']?.toString(),
      documentNumber: json['document_number']?.toString(),
      isVerified: json['is_verified'] ?? false,
      uploadedAt: json['uploaded_at']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    documentFile,
    documentName,
    documentNumber,
    isVerified,
    uploadedAt,
  ];
}
