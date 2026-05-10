import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — required before any Firebase service call
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization can fail gracefully when running in local/dev mode
    // The app will fall back to the Node.js/MongoDB backend
    debugPrint('Firebase init skipped (dev mode): $e');
  }

  runApp(
    DevicePreview(
      enabled: false,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const ProviderScope(child: GraduWayApp()),
    ),
  );
}
