/// App Theme - Spy/Agent Theme Colors and Styles
///
/// Color palette mirroring the Kotlin project.

import 'package:flutter/material.dart';

/// Spy/Agent Theme Color Palette
class AppColors {
  // Primary Dark Theme
  static const Color darkNavy = Color(0xFF0D1B2A);
  static const Color midnightBlue = Color(0xFF1B263B);
  static const Color slateGray = Color(0xFF415A77);
  static const Color steelBlue = Color(0xFF778DA9);
  static const Color offWhite = Color(0xFFE0E1DD);

  // Accent Colors
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color accentTeal = Color(0xFF00BFA5);

  // Utility colors
  static const Color errorRed = Color(0xFFEF5350);
  static const Color successGreen = Color(0xFF66BB6A);
}

/// App Theme Data
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkNavy,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkNavy,
        primary: AppColors.accentGold,
        secondary: AppColors.accentGreen,
        tertiary: AppColors.accentOrange,
        error: AppColors.errorRed,
      ),
      cardTheme: CardTheme(
        color: AppColors.midnightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkNavy,
        foregroundColor: AppColors.offWhite,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.darkNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.offWhite,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.offWhite,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColors.offWhite,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.offWhite,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.offWhite),
        bodyMedium: TextStyle(color: AppColors.steelBlue),
        labelLarge: TextStyle(color: AppColors.offWhite),
        labelMedium: TextStyle(color: AppColors.steelBlue),
        labelSmall: TextStyle(color: AppColors.steelBlue),
      ),
    );
  }
}
