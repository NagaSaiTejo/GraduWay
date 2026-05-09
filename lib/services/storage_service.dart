import 'dart:io';

class StorageService {
  /// Simulates file upload to Firebase Storage and returns a mock URL.
  /// In a real implementation, this would use firebase_storage package.
  static Future<String> uploadFile(File file, String folder) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final fileName = file.path.split('/').last;
    // Mock URL returned after "upload"
    return "https://firebasestorage.googleapis.com/v0/b/graduway/o/$folder%2F$fileName?alt=media";
  }
}
