// Stub for non-web platforms (Android, iOS, Windows, macOS, Linux).
// The real implementation uses file_picker on these platforms.

/// Not used on non-web platforms \u2014 returns null always.
/// The student registration screen uses file_picker directly on non-web.
Future<Map<String, dynamic>?> pickPdfFilePlatform(int maxBytes) async {
  return null;
}
