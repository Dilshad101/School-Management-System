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
}
