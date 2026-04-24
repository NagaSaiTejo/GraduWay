import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'app.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const ProviderScope(child: GraduWayApp()),
    ),
  );
}
