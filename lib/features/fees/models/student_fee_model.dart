import 'package:equatable/equatable.dart';

/// Model for academic year details in fee response.
class AcademicYearDetails extends Equatable {
  const AcademicYearDetails({required this.id, required this.name});

  final String id;
  final String name;

  factory AcademicYearDetails.fromJson(Map<String, dynamic> json) {
    return AcademicYearDetails(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Enum representing fee payment status.
enum FeeStatus { paid, partial, unpaid }

/// Model for student fee details.
class StudentFeeModel extends Equatable {
  const StudentFeeModel({
    required this.id,
    required this.studentName,
    required this.classroomName,
    required this.totalFee,
    required this.paidFee,
    required this.dues,
    required this.totalPaid,
    required this.academicYear,
    this.academicYearDetails,
  });

  final String id;
  final String studentName;
  final String classroomName;
  final double totalFee;
  final double paidFee;
  final double dues;
  final double totalPaid;
  final String academicYear;
  final AcademicYearDetails? academicYearDetails;

  /// Get the fee status based on payment.
  FeeStatus get status {
    if (dues <= 0 && totalFee > 0) {
      return FeeStatus.paid;
    } else if (paidFee > 0 && dues > 0) {
      return FeeStatus.partial;
    } else if (paidFee == 0 && totalFee > 0) {
      return FeeStatus.unpaid;
    } else if (totalFee == 0 && paidFee > 0) {
      // Overpaid or advance payment scenario
      return FeeStatus.paid;
    }
    return FeeStatus.unpaid;
  }

  /// Format amount with currency symbol.
  String formatAmount(double amount) {
    final absAmount = amount.abs();
    if (absAmount >= 1000) {
      return '₹${absAmount.toStringAsFixed(0)}';
    }
    return '₹${absAmount.toStringAsFixed(2)}';
  }

  /// Get formatted total fee.
  String get formattedTotalFee => formatAmount(totalFee);

  /// Get formatted paid fee.
  String get formattedPaidFee => formatAmount(paidFee);

  /// Get formatted dues.
  String get formattedDues => formatAmount(dues);

  factory StudentFeeModel.fromJson(Map<String, dynamic> json) {
    return StudentFeeModel(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      classroomName: json['classroom_name']?.toString() ?? '',
      totalFee: _parseDouble(json['total_fee']),
      paidFee: _parseDouble(json['paid_fee']),
      dues: _parseDouble(json['dues']),
      totalPaid: _parseDouble(json['total_paid']),
      academicYear: json['academic_year']?.toString() ?? '',
      academicYearDetails: json['academic_year_details'] != null
          ? AcademicYearDetails.fromJson(
              json['academic_year_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [
    id,
    studentName,
    classroomName,
    totalFee,
    paidFee,
    dues,
    totalPaid,
    academicYear,
    academicYearDetails,
  ];
}

/// Model for paginated student fee response.
class StudentFeeListResponse extends Equatable {
  const StudentFeeListResponse({
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
  final List<StudentFeeModel> results;

  factory StudentFeeListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return StudentFeeListResponse(
      count: data['count'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 10,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['next'] != null,
      hasPrevious: data['previous'] != null,
      results:
          (data['results'] as List<dynamic>?)
              ?.map((e) => StudentFeeModel.fromJson(e as Map<String, dynamic>))
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
