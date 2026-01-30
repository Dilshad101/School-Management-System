class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String superAdminHome = '/super';
  static const String schools = '/super/schools';

  static const String home = '/home'; // for school admin/teacher/parent/student

  static const String students = '/students';
  static const String studentDetail = '/students/:id';
  static const String createStudent = '/students-create';
  static const String employees = '/employees';
  // static const String employeeDetail = '/employees/:id';
  static const String createEmployee = '/employees-create';
  static const String classes = '/classes';
  static const String classDetail = '/classes/:id';
  static const String createClass = '/classes-create';
  static const String guardians = '/guardians';

  static const String attendance = '/attendance';
  static const String fees = '/fees';
  static const String features = '/features';
  static const String chat = '/chat';
  static const String profile = '/profile';

  static const String userRequests = '/user-requests';
}
