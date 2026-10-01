import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds Flutter's ThemeData objects — one for light mode, one for dark.
/// MaterialApp.router takes BOTH, plus a `themeMode` that decides which
/// one is actually shown (light / dark / follow system setting).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      ),
      textTheme: TextTheme(
        headlineSmall: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
        bodyMedium: const TextStyle(color: AppColors.lightTextPrimary),
        bodySmall: const TextStyle(color: AppColors.lightTextSecondary),
      ),
    );
    return base.copyWith(textTheme: GoogleFonts.interTextTheme(base.textTheme));
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: const Color(0xFF66BB6A), // lighter green reads better on dark
        secondary: const Color(0xFFEF5350),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: Colors.white.withValues(alpha: 0.12),
      ),
      textTheme: TextTheme(
        headlineSmall: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTextPrimary),
        bodyMedium: const TextStyle(color: AppColors.darkTextPrimary),
        bodySmall: const TextStyle(color: AppColors.darkTextSecondary),
      ),
    );
    return base.copyWith(textTheme: GoogleFonts.interTextTheme(base.textTheme));
  }
}
