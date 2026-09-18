import 'package:flutter/material.dart';

/// All the app's colors live here, in ONE place, split into light-mode
/// and dark-mode variants. This means if you ever want to change the
/// brand color, you change it once here — not hunt through every screen.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF1B5E20); // deep green — "Bull" energy
  static const secondary = Color(0xFFB71C1C); // deep red — "Bear" energy

  // Gain/loss colors stay the same in both themes — green/red is a
  // universal stock-market convention, so we don't want it shifting.
  static const gain = Color(0xFF2E7D32);
  static const loss = Color(0xFFC62828);

  // Light theme surface colors
  static const lightBackground = Color(0xFFF7F7F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF6E6E6E);

  // Dark theme surface colors
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkTextPrimary = Color(0xFFF2F2F2);
  static const darkTextSecondary = Color(0xFFA0A0A0);
}
