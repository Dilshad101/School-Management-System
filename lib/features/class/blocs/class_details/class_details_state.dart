import 'package:equatable/equatable.dart';

import '../../models/classroom_model.dart';

enum ClassDetailsStatus { initial, loading, success, failure }

class ClassDetailsState extends Equatable {
  const ClassDetailsState({
    this.status = ClassDetailsStatus.initial,
    this.classroom,
    this.error,
  });

  final ClassDetailsStatus status;
  final ClassroomModel? classroom;
  final String? error;

  bool get isLoading => status == ClassDetailsStatus.loading;
  bool get isSuccess => status == ClassDetailsStatus.success;
  bool get hasError => status == ClassDetailsStatus.failure;

  ClassDetailsState copyWith({
    ClassDetailsStatus? status,
    ClassroomModel? classroom,
    String? error,
  }) {
    return ClassDetailsState(
      status: status ?? this.status,
      classroom: classroom ?? this.classroom,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, classroom, error];
}
