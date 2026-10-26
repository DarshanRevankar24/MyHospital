// lib/services/auth_service.dart
//
// Centralised biometric privacy-lock service.
//
// Responsibilities:
//   • Stores app-lock enabled flag + inactivity timeout in SharedPreferences.
//   • Tracks whether the current session is authenticated (unlocked).
//   • Starts / resets an inactivity timer that re-locks the app.
//   • Exposes authenticate() for any widget that wants biometric confirmation.
//   • Never stores biometric templates; only a transient in-memory boolean.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Result returned by every authenticate() call ──────────────────────────────
enum AuthResult {
  success,
  cancelled,       // user pressed back / cancel
  unavailable,     // no enrolled biometric / hardware absent
  lockedOut,       // device temporarily / permanently locked
  error,           // any other platform error
}

// ── Timeout options (label → seconds; 0 = never) ─────────────────────────────
const Map<String, int> kTimeoutOptions = {
  'Immediately': 0,
  '30 seconds': 30,
  '1 minute': 60,
  '5 minutes': 300,
  '15 minutes': 900,
  'Never': -1,
};

class AuthService extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // ── Persisted prefs keys ───────────────────────────────────────────────────
  static const _kEnabled = 'applock_enabled';
  static const _kTimeout = 'applock_timeout_label';

  // ── State ──────────────────────────────────────────────────────────────────
  bool _appLockEnabled = false;
  String _timeoutLabel = '1 minute';
  bool _isLocked = false;          // true → lock screen should show
  bool _isAuthenticating = false;  // guard against double-prompt
  Timer? _inactivityTimer;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get appLockEnabled => _appLockEnabled;
  bool get isLocked       => _isLocked;
  bool get isAuthenticating => _isAuthenticating;
  String get timeoutLabel => _timeoutLabel;
  int get timeoutSeconds  => kTimeoutOptions[_timeoutLabel] ?? 60;

  // ── Initialise from SharedPreferences ─────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _appLockEnabled = prefs.getBool(_kEnabled) ?? false;
    _timeoutLabel   = prefs.getString(_kTimeout) ?? '1 minute';

    // Lock on first launch if app lock is enabled
    if (_appLockEnabled) {
      _isLocked = true;
    }
    notifyListeners();
  }

  // ── Persist settings ───────────────────────────────────────────────────────
  Future<void> setAppLockEnabled(bool value) async {
    _appLockEnabled = value;
    if (!value) {
      _isLocked = false;
      _cancelTimer();
    } else {
      _isLocked = true; // require immediate auth when user enables lock
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
    notifyListeners();
  }

  Future<void> setTimeoutLabel(String label) async {
    _timeoutLabel = label;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTimeout, label);
    notifyListeners();
  }

  // ── Lifecycle hooks (called from main.dart AppLifecycleObserver) ──────────
  void onAppResumed() {
    // If lock is enabled and the inactivity timer already fired → stay locked.
    // If lock is enabled and the timer has NOT fired → unlock is fine; reset timer.
    if (_appLockEnabled && !_isLocked) {
      _resetTimer();
    }
  }

  void onAppPaused() {
    if (_appLockEnabled) {
      _startTimer();
    }
  }

  /// Called by screens on any meaningful user interaction to reset inactivity.
  void recordActivity() {
    if (_appLockEnabled && !_isLocked) {
      _resetTimer();
    }
  }

  // ── Biometric prompt ───────────────────────────────────────────────────────
  /// Attempt authentication.  Returns [AuthResult] and, on success, marks the
  /// session as unlocked and starts the inactivity timer.
  Future<AuthResult> authenticate({
    String localizedReason = 'Authenticate to access MyHospital',
    bool stickyAuth = true,
  }) async {
    if (_isAuthenticating) return AuthResult.cancelled;

    // Check hardware/enrollment
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return AuthResult.unavailable;
    }

    if (!canCheckBiometrics) {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) return AuthResult.unavailable;
    }

    _isAuthenticating = true;
    notifyListeners();

    try {
      final success = await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'MyHospital App Lock',
            biometricHint: 'Touch the sensor',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: false, // allow device PIN as fallback
          useErrorDialogs: true,
        ),
      );

      if (success) {
        _isLocked = false;
        _isAuthenticating = false;
        _resetTimer();
        notifyListeners();
        return AuthResult.success;
      } else {
        _isAuthenticating = false;
        notifyListeners();
        return AuthResult.cancelled;
      }
    } on PlatformException catch (e) {
      _isAuthenticating = false;
      notifyListeners();
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        return AuthResult.unavailable;
      }
      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        return AuthResult.lockedOut;
      }
      return AuthResult.error;
    }
  }

  /// Used for one-off confirmation (e.g. viewing health records) without
  /// touching the global lock state.
  Future<AuthResult> confirmIdentity({
    String reason = 'Confirm your identity to view this content',
  }) async {
    return authenticate(localizedReason: reason, stickyAuth: false);
  }

  // ── Lock / Unlock helpers ─────────────────────────────────────────────────
  void lock() {
    _isLocked = true;
    _cancelTimer();
    notifyListeners();
  }

  // ── Inactivity timer ──────────────────────────────────────────────────────
  void _startTimer() {
    _cancelTimer();
    final secs = timeoutSeconds;
    if (secs < 0) return; // Never
    if (secs == 0) {
      // Immediately
      _isLocked = true;
      notifyListeners();
      return;
    }
    _inactivityTimer = Timer(Duration(seconds: secs), () {
      _isLocked = true;
      notifyListeners();
    });
  }

  void _resetTimer() {
    _cancelTimer();
    _startTimer();
  }

  void _cancelTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
