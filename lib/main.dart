import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/hospital_screen.dart';
import 'screens/lab_tests_screen.dart';
import 'screens/pharmacy_screen.dart';
import 'screens/blood_bank_screen.dart';
import 'screens/ambulance_screen.dart';
import 'screens/medications_screen.dart';
import 'screens/family_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  runApp(const MyHospitalApp());
}

class MyHospitalApp extends StatelessWidget {
  const MyHospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyHospital – Compassionate Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4F8A),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      builder: (context, child) =>
          _AppSecurityGate(child: child ?? const SizedBox.shrink()),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/hospitals': (context) => const HospitalScreen(),
        '/lab-tests': (context) => const LabTestsScreen(),
        '/pharmacy': (context) => const PharmacyScreen(),
        '/blood-bank': (context) => const BloodBankScreen(),
        '/ambulance': (context) => const AmbulanceScreen(),
        '/medications': (context) => const MedicationsScreen(),
        '/family': (context) => const FamilyScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class _AppSecurityGate extends StatefulWidget {
  final Widget child;

  const _AppSecurityGate({required this.child});

  @override
  State<_AppSecurityGate> createState() => _AppSecurityGateState();
}

class _AppSecurityGateState extends State<_AppSecurityGate>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool _resumePromptInProgress = false;
  String? _authenticationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _authService.isLocked) {
        _authenticateAfterResume();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _authService.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _authService.onAppResumed();
      if (_authService.isLocked) {
        _authenticateAfterResume();
      }
    }
  }

  Future<void> _authenticateAfterResume() async {
    if (_resumePromptInProgress || !_authService.isLocked) return;
    _resumePromptInProgress = true;
    try {
      final result = await _authService.authenticate(
        localizedReason: 'Unlock MyHospital with your device security',
      );
      if (mounted) {
        setState(() {
          _authenticationError = switch (result) {
            AuthResult.success => null,
            AuthResult.unavailable =>
              'Device biometrics or a screen lock are not available.',
            AuthResult.lockedOut =>
              'Device authentication is locked. Try again later.',
            AuthResult.cancelled => 'Authentication was cancelled.',
            AuthResult.error => 'Authentication failed. Try again.',
          };
        });
      }
    } finally {
      _resumePromptInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authService,
      builder: (context, _) => Focus(
        onKeyEvent: (node, event) {
          _authService.recordActivity();
          return KeyEventResult.ignored;
        },
        child: Listener(
          onPointerDown: (_) => _authService.recordActivity(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              if (_authService.appLockEnabled && _authService.isLocked)
                _AppLockOverlay(
                  isAuthenticating: _authService.isAuthenticating,
                  errorMessage: _authenticationError,
                  onUnlock: _authenticateAfterResume,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppLockOverlay extends StatelessWidget {
  final bool isAuthenticating;
  final String? errorMessage;
  final VoidCallback onUnlock;

  const _AppLockOverlay({
    required this.isAuthenticating,
    required this.errorMessage,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: const Color(0xFF0B1728),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fingerprint_rounded,
                    color: Colors.white,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MyHospital is locked',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock with your device fingerprint, face, or screen lock.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: isAuthenticating ? null : onUnlock,
                    icon: isAuthenticating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_open_rounded),
                    label: Text(
                      isAuthenticating ? 'Authenticating…' : 'Unlock app',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
