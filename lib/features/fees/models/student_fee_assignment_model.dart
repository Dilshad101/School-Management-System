import 'package:equatable/equatable.dart';

/// Model representing a student fee assignment.
class StudentFeeAssignmentModel extends Equatable {
  const StudentFeeAssignmentModel({
    required this.id,
    required this.studentId,
    required this.academicYearId,
    required this.feeStructureId,
    this.totalAmount,
    this.totalPaid,
    this.isFullyPaid = false,
    this.createdAt,
    this.installments = const [],
    this.payments = const [],
  });

  final String id;
  final String studentId;
  final String academicYearId;
  final String feeStructureId;
  final String? totalAmount;
  final String? totalPaid;
  final bool isFullyPaid;
  final String? createdAt;
  final List<dynamic> installments;
  final List<dynamic> payments;

  factory StudentFeeAssignmentModel.fromJson(Map<String, dynamic> json) {
    return StudentFeeAssignmentModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student']?.toString() ?? '',
      academicYearId: json['academic_year']?.toString() ?? '',
      feeStructureId: json['fee_structure']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString(),
      totalPaid: json['total_paid']?.toString(),
      isFullyPaid: json['is_fully_paid'] ?? false,
      createdAt: json['created_at']?.toString(),
      installments: json['installments'] as List<dynamic>? ?? [],
      payments: json['payments'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': studentId,
      'academic_year': academicYearId,
      'fee_structure': feeStructureId,
      'total_amount': totalAmount ?? '0',
    };
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    academicYearId,
    feeStructureId,
    totalAmount,
    totalPaid,
    isFullyPaid,
    createdAt,
    installments,
    payments,
  ];
}
