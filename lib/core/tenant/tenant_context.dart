// Only needed for super admin (or anyone who can switch between schools).
class TenantContext {
  String? _selectedSchoolId;

  String? get selectedSchoolId => _selectedSchoolId;

  void selectSchool(String schoolId) {
    _selectedSchoolId = schoolId;
  }

  void clear() {
    _selectedSchoolId = null;
  }
}
