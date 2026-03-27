import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/tenant/tenant_context.dart';
import '../../../../core/utils/di.dart';
import '../../repositories/employees_repository.dart';
import 'employee_details_state.dart';

class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  EmployeeDetailsCubit({required EmployeesRepository employeesRepository})
    : _employeesRepository = employeesRepository,
      super(const EmployeeDetailsState());

  final EmployeesRepository _employeesRepository;

  /// Fetches employee details by ID.
  Future<void> fetchEmployeeDetails(String employeeId) async {
    emit(state.copyWith(status: EmployeeDetailsStatus.loading));

    try {
      final employee = await _employeesRepository.getEmployeeById(employeeId);
      emit(
        state.copyWith(
          status: EmployeeDetailsStatus.success,
          employee: employee,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EmployeeDetailsStatus.failure,
          error: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Toggles the employee's active status.
  Future<void> toggleActiveStatus(String employeeId, bool isActive) async {
    emit(state.copyWith(isTogglingActive: true));

    try {
      final schoolId = _getSchoolId();
      final payload = {'is_active': isActive, 'school': schoolId};

      final updatedEmployee = await _employeesRepository.updateEmployee(
        employeeId,
        payload,
      );

      emit(state.copyWith(employee: updatedEmployee, isTogglingActive: false));
    } catch (e) {
      emit(
        state.copyWith(
          isTogglingActive: false,
          actionStatus: EmployeeDetailsActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
    }
  }

  /// Deletes the employee.
  Future<bool> deleteEmployee(String employeeId) async {
    emit(state.copyWith(actionStatus: EmployeeDetailsActionStatus.loading));

    try {
      await _employeesRepository.deleteEmployee(employeeId);
      emit(state.copyWith(actionStatus: EmployeeDetailsActionStatus.success));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: EmployeeDetailsActionStatus.failure,
          actionError: _getErrorMessage(e),
        ),
      );
      return false;
    }
  }

  /// Toggles edit mode.
  void toggleEditMode() {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  /// Clears the action status.
  void clearActionStatus() {
    emit(
      state.copyWith(
        actionStatus: EmployeeDetailsActionStatus.idle,
        actionError: null,
      ),
    );
  }

  String _getSchoolId() {
    final session = locator<SessionHolder>().session;
    if (session?.schoolId != null && session!.schoolId!.isNotEmpty) {
      return session.schoolId!;
    }
    return locator<TenantContext>().selectedSchoolId ?? '';
  }

  /// Extracts a user-friendly error message from an exception.
  String _getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
