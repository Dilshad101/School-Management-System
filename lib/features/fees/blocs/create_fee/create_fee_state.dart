import 'package:equatable/equatable.dart';

import '../../models/student_fee_assignment_model.dart';

enum CreateFeeStatus { initial, loading, success, failure }

class CreateFeeState extends Equatable {
  const CreateFeeState({
    this.status = CreateFeeStatus.initial,
    this.createdFee,
    this.error,
  });

  final CreateFeeStatus status;
  final StudentFeeAssignmentModel? createdFee;
  final String? error;

  bool get isLoading => status == CreateFeeStatus.loading;
  bool get isSuccess => status == CreateFeeStatus.success;
  bool get isFailure => status == CreateFeeStatus.failure;

  CreateFeeState copyWith({
    CreateFeeStatus? status,
    StudentFeeAssignmentModel? createdFee,
    String? error,
  }) {
    return CreateFeeState(
      status: status ?? this.status,
      createdFee: createdFee ?? this.createdFee,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, createdFee, error];
}
