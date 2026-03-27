import 'package:equatable/equatable.dart';

/// Model for fee payment record from student fee details API.
class FeePaymentModel extends Equatable {
  const FeePaymentModel({
    required this.id,
    this.paymentDate,
    this.amount,
    this.paymentMode,
    this.referenceId,
    this.studentId,
    this.studentName,
    this.classroomId,
    this.classroomName,
    this.academicYearId,
    this.academicYearName,
    this.feeStructureId,
    this.feeStructureName,
    this.totalFee,
    this.totalPaid,
    this.pendingAmount,
  });

  final String id;
  final String? paymentDate;
  final String? amount;
  final String? paymentMode;
  final String? referenceId;
  final String? studentId;
  final String? studentName;
  final String? classroomId;
  final String? classroomName;
  final String? academicYearId;
  final String? academicYearName;
  final String? feeStructureId;
  final String? feeStructureName;
  final String? totalFee;
  final String? totalPaid;
  final double? pendingAmount;

  /// Parses amount string to double.
  double get amountValue => double.tryParse(amount ?? '0') ?? 0;
  double get totalFeeValue => double.tryParse(totalFee ?? '0') ?? 0;
  double get totalPaidValue => double.tryParse(totalPaid ?? '0') ?? 0;
  double get pendingValue => pendingAmount ?? 0;

  /// Formats payment date.
  String get formattedDate {
    if (paymentDate == null) return '---';
    try {
      final date = DateTime.parse(paymentDate!);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return paymentDate!;
    }
  }

  factory FeePaymentModel.fromJson(Map<String, dynamic> json) {
    return FeePaymentModel(
      id: json['id']?.toString() ?? '',
      paymentDate: json['payment_date']?.toString(),
      amount: json['amount']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      referenceId: json['reference_id']?.toString(),
      studentId: json['student_id']?.toString(),
      studentName: json['student_name']?.toString(),
      classroomId: json['classroom_id']?.toString(),
      classroomName: json['classroom_name']?.toString(),
      academicYearId: json['academic_year_id']?.toString(),
      academicYearName: json['academic_year_name']?.toString(),
      feeStructureId: json['fee_structure_id']?.toString(),
      feeStructureName: json['fee_structure_name']?.toString(),
      totalFee: json['total_fee']?.toString(),
      totalPaid: json['total_paid']?.toString(),
      pendingAmount: _parseDouble(json['pending_amount']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    paymentDate,
    amount,
    paymentMode,
    referenceId,
    studentId,
    studentName,
    classroomId,
    classroomName,
    academicYearId,
    academicYearName,
    feeStructureId,
    feeStructureName,
    totalFee,
    totalPaid,
    pendingAmount,
  ];
}

/// Model for fee summary from student fee details API.
class FeeSummaryModel extends Equatable {
  const FeeSummaryModel({
    this.totalFee = 0,
    this.totalPaid = 0,
    this.pendingFee = 0,
  });

  final double totalFee;
  final double totalPaid;
  final double pendingFee;

  factory FeeSummaryModel.fromJson(Map<String, dynamic> json) {
    return FeeSummaryModel(
      totalFee: _parseDouble(json['total_fee']) ?? 0,
      totalPaid: _parseDouble(json['total_paid']) ?? 0,
      pendingFee: _parseDouble(json['pending_fee']) ?? 0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [totalFee, totalPaid, pendingFee];
}

/// Response model for student fee details API.
class StudentFeeDetailsResponse extends Equatable {
  const StudentFeeDetailsResponse({
    required this.payments,
    required this.summary,
    this.count = 0,
  });

  final List<FeePaymentModel> payments;
  final FeeSummaryModel summary;
  final int count;

  factory StudentFeeDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final resultsList = data['results'] as List<dynamic>? ?? [];
    final summaryData = data['summary'] as Map<String, dynamic>? ?? {};

    return StudentFeeDetailsResponse(
      payments: resultsList
          .map((e) => FeePaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: FeeSummaryModel.fromJson(summaryData),
      count: data['count'] as int? ?? resultsList.length,
    );
  }

  @override
  List<Object?> get props => [payments, summary, count];
}
