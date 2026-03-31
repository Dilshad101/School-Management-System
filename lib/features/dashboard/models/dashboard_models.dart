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

/// Status for timetable periods.
enum TimetablePeriodStatus { completed, liveNow, upcoming }

/// Model for a timetable period.
class TimetablePeriod extends Equatable {
  const TimetablePeriod({
    required this.id,
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.className,
    required this.roomName,
    required this.status,
  });

  final String id;
  final int periodNumber;
  final String startTime;
  final String endTime;
  final String subjectName;
  final String className;
  final String roomName;
  final TimetablePeriodStatus status;

  factory TimetablePeriod.fromJson(Map<String, dynamic> json) {
    return TimetablePeriod(
      id: json['id']?.toString() ?? '',
      periodNumber: json['period_number'] ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      subjectName: json['subject_name'] ?? '',
      className: json['class_name'] ?? '',
      roomName: json['room_name'] ?? '',
      status: _parseStatus(json['status']),
    );
  }

  static TimetablePeriodStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return TimetablePeriodStatus.completed;
      case 'live_now':
      case 'live':
        return TimetablePeriodStatus.liveNow;
      case 'upcoming':
      default:
        return TimetablePeriodStatus.upcoming;
    }
  }

  String get statusLabel {
    switch (status) {
      case TimetablePeriodStatus.completed:
        return 'Completed';
      case TimetablePeriodStatus.liveNow:
        return 'Live Now';
      case TimetablePeriodStatus.upcoming:
        return 'Upcoming';
    }
  }

  @override
  List<Object?> get props => [
    id,
    periodNumber,
    startTime,
    endTime,
    subjectName,
    className,
    roomName,
    status,
  ];
}

/// Model for dashboard timetable data.
class DashboardTimetable extends Equatable {
  const DashboardTimetable({required this.periods});

  final List<TimetablePeriod> periods;

  factory DashboardTimetable.fromJson(Map<String, dynamic> json) {
    final periodsJson = json['periods'] as List<dynamic>? ?? [];
    return DashboardTimetable(
      periods: periodsJson
          .map((e) => TimetablePeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [periods];
}

/// Payment method for recently paid.
enum PaymentMethod { bank, cash, upi, card }

/// Model for a recently paid fee record.
class RecentlyPaidFee extends Equatable {
  const RecentlyPaidFee({
    required this.id,
    required this.studentName,
    required this.className,
    required this.studentId,
    required this.totalFees,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentMethod,
    required this.paidAt,
  });

  final String id;
  final String studentName;
  final String className;
  final String studentId;
  final double totalFees;
  final double paidAmount;
  final double dueAmount;
  final PaymentMethod paymentMethod;
  final DateTime paidAt;

  factory RecentlyPaidFee.fromJson(Map<String, dynamic> json) {
    return RecentlyPaidFee(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name'] ?? '',
      className: json['class_name'] ?? '',
      studentId: json['student_id'] ?? '',
      totalFees: (json['total_fees'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: _parsePaymentMethod(json['payment_method']),
      paidAt: DateTime.tryParse(json['paid_at'] ?? '') ?? DateTime.now(),
    );
  }

  static PaymentMethod _parsePaymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'bank':
      case 'net_banking':
        return PaymentMethod.bank;
      case 'upi':
        return PaymentMethod.upi;
      case 'card':
        return PaymentMethod.card;
      case 'cash':
      default:
        return PaymentMethod.cash;
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.bank:
        return 'Bank';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
    }
  }

  String get formattedTotalFees => '₹${totalFees.toStringAsFixed(0)}';
  String get formattedPaidAmount => '₹${paidAmount.toStringAsFixed(0)}';
  String get formattedDueAmount => '₹${dueAmount.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
    id,
    studentName,
    className,
    studentId,
    totalFees,
    paidAmount,
    dueAmount,
    paymentMethod,
    paidAt,
  ];
}

/// Model for dashboard recently paid fees data.
class DashboardRecentlyPaid extends Equatable {
  const DashboardRecentlyPaid({required this.payments});

  final List<RecentlyPaidFee> payments;

  factory DashboardRecentlyPaid.fromJson(Map<String, dynamic> json) {
    final paymentsJson = json['payments'] as List<dynamic>? ?? [];
    return DashboardRecentlyPaid(
      payments: paymentsJson
          .map((e) => RecentlyPaidFee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [payments];
}
