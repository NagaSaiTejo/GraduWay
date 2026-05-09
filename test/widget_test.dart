import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/screens/auth/login_screen.dart';
import 'package:graduway/screens/auth/registration_screen.dart';

void main() {
  testWidgets('Login Screen has email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: LoginScreen()),
    ));

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Cleanup for animations
    await tester.pumpAndSettle();
  });

  testWidgets('Registration Screen shows role selection', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: RegistrationScreen()),
    ));

    expect(find.text('I am a...'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Alumni'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
