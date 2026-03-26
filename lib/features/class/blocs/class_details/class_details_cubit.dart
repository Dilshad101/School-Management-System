import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/classroom_repository.dart';
import 'class_details_state.dart';

class ClassDetailsCubit extends Cubit<ClassDetailsState> {
  ClassDetailsCubit({required ClassroomRepository classroomRepository})
    : _classroomRepository = classroomRepository,
      super(const ClassDetailsState());

  final ClassroomRepository _classroomRepository;

  /// Fetches the classroom details by ID.
  Future<void> fetchClassroomDetails(String classroomId) async {
    emit(state.copyWith(status: ClassDetailsStatus.loading));

    try {
      final classroom = await _classroomRepository.getClassroomById(
        classroomId,
      );

      emit(
        state.copyWith(
          status: ClassDetailsStatus.success,
          classroom: classroom,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ClassDetailsStatus.failure, error: e.toString()),
      );
    }
  }

  /// Refreshes the classroom details.
  Future<void> refresh(String classroomId) async {
    await fetchClassroomDetails(classroomId);
  }
}
