class DemoAuthException implements Exception {
  final String message;

  const DemoAuthException(this.message);

  @override
  String toString() => message;
}

class _DemoAccount {
  final String name;
  final String email;
  final String password;

  const _DemoAccount({
    required this.name,
    required this.email,
    required this.password,
  });
}

class DemoAuthService {
  DemoAuthService._();

  static final DemoAuthService instance = DemoAuthService._();
  static const demoEmail = 'demo@myhospital.com';
  static const demoPassword = 'Demo1234!';

  final List<_DemoAccount> _accounts = [
    const _DemoAccount(
      name: 'Demo Patient',
      email: demoEmail,
      password: demoPassword,
    ),
  ];

  Future<void> signIn(String usernameOrEmail, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final username = usernameOrEmail.trim().toLowerCase();
    final accountExists = _accounts.any(
      (account) =>
          (account.email.toLowerCase() == username ||
              account.name.toLowerCase() == username) &&
          account.password == password,
    );

    if (!accountExists) {
      throw const DemoAuthException(
        'Demo sign-in failed. Use the sample credentials or create a demo account.',
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.any(
      (account) => account.email.toLowerCase() == normalizedEmail,
    )) {
      throw const DemoAuthException(
        'A demo account already exists for this email address.',
      );
    }

    _accounts.add(
      _DemoAccount(
        name: name.trim(),
        email: normalizedEmail,
        password: password,
      ),
    );
  }
}
