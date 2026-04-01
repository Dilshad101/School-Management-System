/// Contains all permission constants used in the application.
/// These map to the permission strings returned by the API.
abstract class Permissions {
  // Student permissions
  static const String viewStudent = 'view_student';
  static const String addStudent = 'add_student';
  static const String changeStudent = 'change_student';
  static const String deleteStudent = 'delete_student';
  static const String promoteStudent = 'promote_student';

  // User/Employee permissions
  static const String viewUser = 'view_user';
  static const String addUser = 'add_user';
  static const String changeUser = 'change_user';
  static const String deleteUser = 'delete_user';
  static const String activateUser = 'activate_user';
  static const String deactivateUser = 'deactivate_user';

  // Guardian permissions
  static const String viewGuardian = 'view_guardian';
  static const String addGuardian = 'add_guardian';
  static const String changeGuardian = 'change_guardian';
  static const String deleteGuardian = 'delete_guardian';

  // Fee permissions
  static const String viewFee = 'view_fee';
  static const String changeFee = 'change_fee';
  static const String collectPayment = 'collect_payment';
  static const String refundPayment = 'refund_payment';
  static const String viewStudentFeeHistory = 'view_student_fee_history';
  static const String viewStudentFeeDetails = 'view_student_fee_details';

  // Attendance permissions
  static const String viewAttendance = 'view_attendance';
  static const String markAttendance = 'mark_attendance';
  static const String correctAttendance = 'correct_attendance';
  static const String exportAttendance = 'export_attendance';
  static const String manageAttendanceEvents = 'manage_attendance_events';
  static const String manageAttendanceSources = 'manage_attendance_sources';
  static const String manageAttendanceIdentifiers =
      'manage_attendance_identifiers';

  // Timetable permissions
  static const String viewTimetable = 'view_timetable';
  static const String addTimetable = 'add_timetable';
  static const String changeTimetable = 'change_timetable';
  static const String deleteTimetable = 'delete_timetable';
  static const String viewTimetableAvailability = 'view_timetable_availability';
  static const String viewTeacherTimetable = 'view_teacher_timetable';
  static const String viewStudentTimetable = 'view_student_timetable';
  static const String viewGuardianTimetable = 'view_guardian_timetable';

  // Classroom permissions
  static const String viewClassroom = 'view_classroom';
  static const String addClassroom = 'add_classroom';
  static const String changeClassroom = 'change_classroom';
  static const String deleteClassroom = 'delete_classroom';

  // Subject permissions
  static const String viewSubject = 'view_subject';
  static const String addSubject = 'add_subject';
  static const String changeSubject = 'change_subject';
  static const String deleteSubject = 'delete_subject';

  // Academic Year permissions
  static const String viewAcademicYear = 'view_academic_year';
  static const String addAcademicYear = 'add_academic_year';
  static const String changeAcademicYear = 'change_academic_year';
  static const String deleteAcademicYear = 'delete_academic_year';

  // Period permissions
  static const String viewPeriod = 'view_period';
  static const String addPeriod = 'add_period';
  static const String changePeriod = 'change_period';
  static const String deletePeriod = 'delete_period';

  // Role permissions
  static const String viewRole = 'view_role';
  static const String addRole = 'add_role';
  static const String changeRole = 'change_role';
  static const String deleteRole = 'delete_role';
  static const String assignRole = 'assign_role';
  static const String viewPermission = 'view_permission';

  // School permissions
  static const String viewSchool = 'view_school';
  static const String addSchool = 'add_school';
  static const String changeSchool = 'change_school';
  static const String deleteSchool = 'delete_school';
  static const String manageSchoolSettings = 'manage_school_settings';
  static const String viewSchoolType = 'view_school_type';
  static const String addSchoolType = 'add_school_type';
  static const String changeSchoolType = 'change_school_type';
  static const String deleteSchoolType = 'delete_school_type';

  // Exam & Marks permissions
  static const String viewExam = 'view_exam';
  static const String addExam = 'add_exam';
  static const String publishExam = 'publish_exam';
  static const String viewMarks = 'view_marks';
  static const String addMarks = 'add_marks';
  static const String publishMarks = 'publish_marks';

  // Notification permissions
  static const String viewNotification = 'view_notification';
  static const String changeNotification = 'change_notification';
  static const String deleteNotification = 'delete_notification';
  static const String sendNotification = 'send_notification';

  // Chat permissions
  static const String viewChat = 'view_chat';
  static const String sendMessage = 'send_message';

  // Transport permissions
  static const String viewTransport = 'view_transport';
  static const String addTransport = 'add_transport';
  static const String changeTransport = 'change_transport';
  static const String deleteTransport = 'delete_transport';
  static const String addTransportEvent = 'add_transport_event';
  static const String viewStudentTransportStatus =
      'view_student_transport_status';

  // Subscription & Plan permissions
  static const String viewSubscription = 'view_subscription';
  static const String addSubscription = 'add_subscription';
  static const String changeSubscription = 'change_subscription';
  static const String deleteSubscription = 'delete_subscription';
  static const String viewPlan = 'view_plan';
  static const String addPlan = 'add_plan';
  static const String changePlan = 'change_plan';
  static const String deletePlan = 'delete_plan';

  // Feature permissions
  static const String viewFeature = 'view_feature';
  static const String addFeature = 'add_feature';
  static const String changeFeature = 'change_feature';
  static const String deleteFeature = 'delete_feature';

  // Device permissions
  static const String viewDevice = 'view_device';
  static const String addDevice = 'add_device';
  static const String changeDevice = 'change_device';
  static const String deleteDevice = 'delete_device';

  // User School permissions
  static const String viewUserSchool = 'view_user_school';
  static const String addUserSchool = 'add_user_school';
  static const String changeUserSchool = 'change_user_school';
  static const String deleteUserSchool = 'delete_user_school';

  // Report & Dashboard permissions
  static const String viewReports = 'view_reports';
  static const String exportReports = 'export_reports';
  static const String viewAuditLogs = 'view_audit_logs';
  static const String accessAdminDashboard = 'access_admin_dashboard';
  static const String viewProfile = 'view_profile';
}
