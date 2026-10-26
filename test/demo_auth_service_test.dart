import 'package:flutter_test/flutter_test.dart';
import 'package:myhospital/services/demo_auth_service.dart';

void main() {
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
}
