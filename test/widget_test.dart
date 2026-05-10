import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Wait for animations
    await tester.pumpAndSettle();

    // Find fields
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('LoginScreen form validation triggers on empty submit', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the sign in button without entering data
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Expect validation errors
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('LoginScreen validates incorrect email format', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Enter invalid email
    final emailField = find.widgetWithText(TextFormField, 'Email Address');
    await tester.enterText(emailField, 'invalidemail');
    
    // Tap sign in
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Expect specific validation error
    expect(find.text('Enter a valid email'), findsOneWidget);
  });
}
