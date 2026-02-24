enum Env { prod, dev }

class Endpoints {
  Endpoints._();

  /// Environment enum
  /// Set the environment here to switch between development and production
  static const Env _environment = Env.dev;

  /// Base URL based on the environment
  static String get baseUrl {
    switch (_environment) {
      case Env.prod:
        return _productionUrl;
      case Env.dev:
        return _developmentUrl;
    }
  }

  static const String _developmentUrl = 'https://api.dev.waad.co.in/api';
  static const String _productionUrl = 'https://api.dev.waad.co.in/api';

  // Auth endpoints
  static const String login = '/v1/login-web/';
  static const String me = '/v1/me/';

  // Students endpoints
  static const String students = '/v1/student-users/';

  // Academics endpoints
  static const String classRooms = '/v1/academics/classrooms/';
  static const String academicYears = '/v1/academics/academic-years/';

  // Employees/School Users endpoints
  static const String schoolUsers = '/v1/school-users/';

  // Roles endpoints
  static const String roles = '/v1/roles/';

  // Subjects endpoints
  static const String subjects = '/v1/academics/subjects/';

  // Guardians endpoints
  static const String guardians = '/v1/guardian-users/';

  // Notifications endpoints
  static const String notifications = '/v1/notification/notification/';

  // Chat/Communication endpoints
  static const String chat = '/v1/communication/chat/';
  static const String chatStartChat = '/v1/communication/chat/start_chat/';
  static const String chatSendMessage = '/v1/communication/chat/send_message/';
  static String chatConversation(String conversationId) =>
      '/v1/communication/chat/conversation/$conversationId/';
  static String chatMarkRead(String conversationId) =>
      '/v1/communication/chat/conversation/$conversationId/mark-read/';
}
