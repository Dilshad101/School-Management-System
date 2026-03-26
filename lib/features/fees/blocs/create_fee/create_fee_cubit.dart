import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/fees_repository.dart';
import 'create_fee_state.dart';

class CreateFeeCubit extends Cubit<CreateFeeState> {
  CreateFeeCubit({
    required FeesRepository feesRepository,
    required this.schoolId,
  }) : _feesRepository = feesRepository,
       super(const CreateFeeState());

  final FeesRepository _feesRepository;
  final String schoolId;

  /// Creates a new student fee assignment.
  Future<void> createStudentFee({
    required String studentId,
    required String academicYearId,
    required String feeStructureId,
  }) async {
    emit(state.copyWith(status: CreateFeeStatus.loading));

    try {
      final createdFee = await _feesRepository.createStudentFee(
        studentId: studentId,
        academicYearId: academicYearId,
        feeStructureId: feeStructureId,
        schoolId: schoolId,
      );

      emit(
        state.copyWith(status: CreateFeeStatus.success, createdFee: createdFee),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CreateFeeStatus.failure, error: e.toString()),
      );
    }
  }

  /// Resets the state to initial.
  void reset() {
    emit(const CreateFeeState());
  }
}
