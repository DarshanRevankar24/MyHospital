import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myhospital/screens/login_screen.dart';
import 'package:myhospital/services/demo_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('sign in screen opens dashboard with demo account', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
        routes: {
          '/dashboard': (_) =>
              const Scaffold(body: Center(child: Text('Demo dashboard'))),
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), DemoAuthService.demoEmail);
    await tester.enterText(fields.at(1), DemoAuthService.demoPassword);
    await tester.tap(find.text('Sign In'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Demo dashboard'), findsOneWidget);
  });
}
