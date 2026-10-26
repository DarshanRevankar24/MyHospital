import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemoAuthException implements Exception {
  final String message;

  const DemoAuthException(this.message);

  @override
  String toString() => message;
}

class _DemoAccount {
  final String name;
  final String email;
  final String salt;
  final String passwordHash;

  const _DemoAccount({
    required this.name,
    required this.email,
    required this.salt,
    required this.passwordHash,
  });

  factory _DemoAccount.fromJson(Map<String, dynamic> json) => _DemoAccount(
    name: json['name'] as String,
    email: json['email'] as String,
    salt: json['salt'] as String,
    passwordHash: json['passwordHash'] as String,
  );

  Map<String, String> toJson() => {
    'name': name,
    'email': email,
    'salt': salt,
    'passwordHash': passwordHash,
  };
}

class DemoAuthService {
  DemoAuthService._();

  static final DemoAuthService instance = DemoAuthService._();
  static const demoEmail = 'demo@myhospital.com';
  static const demoPassword = 'Demo1234!';
  static const _accountsKey = 'offline_demo_accounts';
  static const _demoSalt = 'myhospital-offline-demo-account-v1';
  static const _passwordIterations = 12000;

  final List<_DemoAccount> _accounts = [];
  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    return _initialization ??= _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAccounts = prefs.getString(_accountsKey);
    if (storedAccounts != null) {
      final decoded = jsonDecode(storedAccounts);
      if (decoded is! List) {
        throw const FormatException(
          'Stored offline demo accounts are invalid.',
        );
      }
      _accounts
        ..clear()
        ..addAll(
          decoded.map((entry) {
            if (entry is! Map) {
              throw const FormatException(
                'Stored offline demo account is invalid.',
              );
            }
            return _DemoAccount.fromJson(Map<String, dynamic>.from(entry));
          }),
        );
    }

    if (!_accounts.any((account) => account.email == demoEmail)) {
      _accounts.add(
        _DemoAccount(
          name: 'Demo Patient',
          email: demoEmail,
          salt: _demoSalt,
          passwordHash: _hashPassword(demoPassword, _demoSalt),
        ),
      );
      await _saveAccounts(prefs);
    }
  }

  Future<void> _saveAccounts(SharedPreferences prefs) async {
    final saved = await prefs.setString(
      _accountsKey,
      jsonEncode(_accounts.map((account) => account.toJson()).toList()),
    );
    if (!saved) {
      throw const DemoAuthException('Could not save the offline demo account.');
    }
  }

  Future<void> signIn(String usernameOrEmail, String password) async {
    await _ensureInitialized();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final username = usernameOrEmail.trim().toLowerCase();
    for (final account in _accounts) {
      if (account.email.toLowerCase() != username &&
          account.name.toLowerCase() != username) {
        continue;
      }
      if (_hashPassword(password, account.salt) == account.passwordHash) {
        return;
      }
      break;
    }

    throw const DemoAuthException(
      'Sign-in failed. Check your email and password, or create a demo account.',
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.any((account) => account.email == normalizedEmail)) {
      throw const DemoAuthException(
        'A demo account already exists for this email address.',
      );
    }

    final salt = _newSalt();
    _accounts.add(
      _DemoAccount(
        name: name.trim(),
        email: normalizedEmail,
        salt: salt,
        passwordHash: _hashPassword(password, salt),
      ),
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await _saveAccounts(prefs);
    } catch (_) {
      _accounts.removeWhere((account) => account.email == normalizedEmail);
      rethrow;
    }
  }

  String _newSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final key = utf8.encode(password);
    final saltBytes = utf8.encode(salt);
    final hmac = Hmac(sha256, key);
    var block = hmac.convert([...saltBytes, 0, 0, 0, 1]).bytes;
    final derived = List<int>.from(block);

    for (var iteration = 1; iteration < _passwordIterations; iteration++) {
      block = hmac.convert(block).bytes;
      for (var index = 0; index < derived.length; index++) {
        derived[index] ^= block[index];
      }
    }

    return base64UrlEncode(derived);
  }
}
