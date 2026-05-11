import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  // Capture Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // Capture platform/async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return false; 
  };

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- GraduWay App Starting ---');

  // Initialize Firebase with timeout to prevent hanging
  try {
    debugPrint('Initializing Firebase (2s timeout)...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 2));
    debugPrint('Firebase initialized successfully.');
  } catch (e) {
    debugPrint('Firebase initialization skipped (expected in dev): $e');
  }

  debugPrint('Running app...');
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        tools: const [...DevicePreview.defaultTools],
        builder: (context) => const GraduWayApp(),
      ),
    ),
  );
}
