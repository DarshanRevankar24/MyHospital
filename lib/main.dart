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
