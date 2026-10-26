import 'package:flutter_test/flutter_test.dart';
import 'package:myhospital/services/demo_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('accepts the built-in demo credentials', () async {
    await DemoAuthService.instance.signIn(
      DemoAuthService.demoEmail,
      DemoAuthService.demoPassword,
    );
  });

  test('registered demo account can sign in without a backend', () async {
    await DemoAuthService.instance.signUp(
      name: 'Local Test Patient',
      email: 'local-test-patient@example.test',
      password: 'LocalTest123!',
    );

    await DemoAuthService.instance.signIn(
      'local-test-patient@example.test',
      'LocalTest123!',
    );
  });

  test(
    'registered accounts survive reload and do not store raw passwords',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final storedAccounts = prefs.getString('offline_demo_accounts')!;
      expect(storedAccounts, contains('local-test-patient@example.test'));
      expect(storedAccounts, isNot(contains('LocalTest123!')));
    },
  );

  test('rejects incorrect credentials', () async {
    await expectLater(
      DemoAuthService.instance.signIn(
        DemoAuthService.demoEmail,
        'incorrect-password',
      ),
      throwsA(isA<DemoAuthException>()),
    );
  });
}
