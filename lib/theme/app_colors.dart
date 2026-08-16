import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Navy Blue Palette (from IMG_3460.png)
  static const navy = Color(0xFF0D1B2E);         // Deep navy (darkest bg)
  static const navyDark = Color(0xFF091420);      // Even darker navy
  static const navyMid = Color(0xFF1A2C4A);       // Mid navy
  static const navyLight = Color(0xFFE8EDF5);     // Soft navy tint (light bg)
  static const navyAccent = Color(0xFF1E3A5F);    // Accent navy

  // ── Brand Blue (primary interactive colour)
  static const blue = Color(0xFF1B4F8A);          // Strong blue
  static const blueDark = Color(0xFF123A6D);      // Darker blue (hover)
  static const blueMid = Color(0xFF2563A8);       // Mid blue
  static const blueLight = Color(0xFFEAF1FB);     // Very light blue tint

  // ── Silver / Steel (matches logo chrome)
  static const silver = Color(0xFFB0BEC5);
  static const silverLight = Color(0xFFECEFF1);

  // ── Accent
  static const accent = Color(0xFFE8545A);        // Red (emergency/destructive)
  static const accentSoft = Color(0xFFFFF0F1);

  // ── Text
  static const textDark = Color(0xFF0D1B2E);
  static const textMid = Color(0xFF3D5270);
  static const textSoft = Color(0xFF8A99B3);

  // ── Borders & Backgrounds
  static const border = Color(0xFFDDE4EF);
  static const bg = Color(0xFFF4F7FC);

  // ── Icon background colours
  static const icRed = Color(0xFFFFF0F1);
  static const icBlue = Color(0xFFE8EDF5);
  static const icPurple = Color(0xFFF3EEFF);
  static const icGreen = Color(0xFFEDF6EE);
  static const icOrange = Color(0xFFFFF7ED);

  // ── Legacy aliases (keep widgets compiling during migration)
  static const teal = blue;
  static const tealDark = blueDark;
  static const tealLight = blueLight;
  static const tealMid = blueMid;
}
