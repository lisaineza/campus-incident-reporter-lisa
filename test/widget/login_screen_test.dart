import 'package:campus_incident_reporter/core/theme/app_theme.dart';
import 'package:campus_incident_reporter/providers/auth_controller.dart';
import 'package:campus_incident_reporter/screens/auth/login_screen.dart';
import 'package:campus_incident_reporter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAuthService service;
  late AuthController controller;

  setUp(() {
    service = FakeAuthService();
    controller = AuthController(service);
  });

  tearDown(() => controller.dispose());

  Future<void> pumpLogin(WidgetTester tester) {
    return tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: controller,
        child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
      ),
    );
  }

  Future<void> tapSignIn(WidgetTester tester) async {
    final button = find.widgetWithText(FilledButton, 'Sign in');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  testWidgets('shows validation errors and does not call the service',
      (tester) async {
    await pumpLogin(tester);
    await tapSignIn(tester);

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(service.signInCalls, 0);
  });

  testWidgets('signs in when the form is valid', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'amina@alustudent.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'campus2026');
    await tapSignIn(tester);

    expect(service.signInCalls, 1);
  });

  testWidgets('surfaces a friendly error from the service', (tester) async {
    service.nextFailure = const AuthFailure('Incorrect email or password.');
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'amina@alustudent.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass1');
    await tapSignIn(tester);
    await tester.pump();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });
}
