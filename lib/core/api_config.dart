class ApiConfig {
  /// The base URL for the Node.js/MongoDB backend API.
  /// Can be overridden at build time using --dart-define=API_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:5000/api',
  );

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String registerStudent = '$baseUrl/auth/register/student';
  static const String registerAlumni = '$baseUrl/auth/register/alumni';
  static const String registerAdmin = '$baseUrl/auth/register/admin';

  // Roadmap Endpoints
  static const String roadmapSelect = '$baseUrl/roadmap/select';
  static const String roadmapExit = '$baseUrl/roadmap/exit';
  static const String roadmapCompleteMilestone = '$baseUrl/roadmap/complete-milestone';

  // Messaging Endpoints
  static const String messagingConnections = '$baseUrl/messages/connections';
  static const String messagingSend = '$baseUrl/messages/send';
  static String chatHistory(String s, String r) => '$baseUrl/messages/$s/$r';
  static String connections(String email) => '$baseUrl/messages/connections/$email';
}
