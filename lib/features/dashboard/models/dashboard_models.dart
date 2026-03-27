import 'package:equatable/equatable.dart';

/// Model for total student and employee count.
class StudentEmployeeCount extends Equatable {
  const StudentEmployeeCount({
    required this.studentCount,
    required this.employeeCount,
  });

  final int studentCount;
  final int employeeCount;

  factory StudentEmployeeCount.fromJson(Map<String, dynamic> json) {
    return StudentEmployeeCount(
      studentCount: json['student_count'] ?? 0,
      employeeCount: json['employee_count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [studentCount, employeeCount];
}

/// Model for total pending fees.
class PendingFees extends Equatable {
  const PendingFees({required this.totalPending});

  final double totalPending;

  factory PendingFees.fromJson(Map<String, dynamic> json) {
    final value = json['total_pending'];
    return PendingFees(totalPending: (value is num) ? value.toDouble() : 0.0);
  }

  /// Formatted total pending amount.
  String get formattedAmount {
    final absValue = totalPending.abs();
    if (absValue >= 100000) {
      return '₹${(absValue / 100000).toStringAsFixed(1)}L';
    } else if (absValue >= 1000) {
      return '₹${(absValue / 1000).toStringAsFixed(1)}K';
    }
    return '₹${absValue.toStringAsFixed(0)}';
  }

  @override
  List<Object?> get props => [totalPending];
}

/// Model for payment method breakdown.
class PaymentMethodAmount extends Equatable {
  const PaymentMethodAmount({required this.method, required this.totalAmount});

  final String method;
  final double totalAmount;

  factory PaymentMethodAmount.fromJson(Map<String, dynamic> json) {
    return PaymentMethodAmount(
      method: json['method'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [method, totalAmount];
}

/// Model for monthly payment data.
class MonthlyPayment extends Equatable {
  const MonthlyPayment({required this.month, required this.payments});

  final String month;
  final List<PaymentMethodAmount> payments;

  factory MonthlyPayment.fromJson(Map<String, dynamic> json) {
    return MonthlyPayment(
      month: json['month'] ?? '',
      payments:
          (json['payments'] as List<dynamic>?)
              ?.map(
                (e) => PaymentMethodAmount.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Get total amount for a specific payment method.
  double getAmountByMethod(String method) {
    final payment = payments.firstWhere(
      (p) => p.method.toLowerCase() == method.toLowerCase(),
      orElse: () => PaymentMethodAmount(method: method, totalAmount: 0),
    );
    return payment.totalAmount;
  }

  /// Get total cash amount (cash method).
  double get cashAmount => getAmountByMethod('cash');

  /// Get total bank amount (net_banking, card, upi combined).
  double get bankAmount {
    return getAmountByMethod('net_banking') +
        getAmountByMethod('card') +
        getAmountByMethod('upi');
  }

  /// Get formatted month name (e.g., "2026-03" -> "Mar").
  String get monthName {
    if (month.isEmpty) return '';
    try {
      final parts = month.split('-');
      if (parts.length >= 2) {
        final monthNum = int.parse(parts[1]);
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        if (monthNum >= 1 && monthNum <= 12) {
          return months[monthNum - 1];
        }
      }
    } catch (_) {}
    return month;
  }

  @override
  List<Object?> get props => [month, payments];
}

/// Model for last six months payments response.
class LastSixMonthsPayments extends Equatable {
  const LastSixMonthsPayments({required this.months});

  final List<MonthlyPayment> months;

  factory LastSixMonthsPayments.fromJson(List<dynamic> json) {
    return LastSixMonthsPayments(
      months: json
          .map((e) => MonthlyPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [months];
}
