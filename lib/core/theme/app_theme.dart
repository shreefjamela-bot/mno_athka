// ==============================
// ملف الثيم — Luxury Dark Theme
// ==============================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

abstract class AppTheme {

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      fontFamily: 'Tajawal',

      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.neonCyan,
        surface: AppColors.background,
        onPrimary: AppColors.background,
        onSecondary: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),

      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          shadowColor: AppColors.glowGold,
          textStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceColor,
        hintStyle: const TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.textHint,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceColor,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.primary.withOpacity(0.15),
        thickness: 1,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.primary,
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Tajawal',
          color: AppColors.textHint,
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
