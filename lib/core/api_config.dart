/// Central API configuration for GraduWay backend.
///
/// All backend URLs are defined here. In production, override via:
///   flutter run --dart-define=API_BASE_URL=https://your-server.com
///
/// Never hardcode localhost URLs in screen files - always use this config.
class ApiConfig {
  ApiConfig._();

  /// The base URL for the Node.js/MongoDB backend API.
  /// Override at build time: --dart-define=API_BASE_URL=https://your-server.com
  static const String _baseHost = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000',
  );

  static const String baseUrl = '$_baseHost/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String registerStudent = '$baseUrl/auth/register/student';
  static const String registerAlumni = '$baseUrl/auth/register/alumni';
  static const String registerAdmin = '$baseUrl/auth/register/admin';

  // Roadmap endpoints
  static const String roadmapSelect = '$baseUrl/roadmap/select';
  static const String roadmapExit = '$baseUrl/roadmap/exit';
  static const String roadmapCompleteMilestone =
      '$baseUrl/roadmap/complete-milestone';

  // Messaging endpoints
  static const String messagingSend = '$baseUrl/messages/send';
  static const String atsScore = '$baseUrl/ats/score';

  // Dynamic routes
  static String chatHistory(String sender, String receiver) =>
      '$baseUrl/messages/$sender/$receiver';

  static String connections(String email) =>
      '$baseUrl/messages/connections/$email';
}
