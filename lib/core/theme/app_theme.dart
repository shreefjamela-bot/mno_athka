// ==============================
// ملف الثيم العام للعبة
// اسم الملف: app_theme.dart
// المكان: lib/core/theme/
//
// هنا نحدد شكل اللعبة كاملاً
// الخطوط، الأزرار، البطاقات، الشريط العلوي
// ==============================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// abstract = كلاس للاستخدام المباشر فقط
abstract class AppTheme {

  // ==============================
  // الثيم الرئيسي للعبة
  // نستدعيه في main.dart مرة وحدة
  // ==============================
  static ThemeData get darkTheme {
    return ThemeData(

      // نوع الثيم — Material 3 أحدث إصدار
      useMaterial3: true,

      // اللون الأساسي للتطبيق
      colorScheme: ColorScheme.dark(
        // اللون الرئيسي
        primary: AppColors.primary,
        // اللون الثاني
        secondary: AppColors.secondary,
        // لون الخلفية
        surface: AppColors.background,
        // لون النصوص على الخلفية
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),

      // لون الخلفية الرئيسية
      scaffoldBackgroundColor: AppColors.background,

      // ==============================
      // ثيم شريط العنوان العلوي
      // ==============================
      appBarTheme: const AppBarTheme(
        // خلفية الشريط
        backgroundColor: AppColors.background,
        // لون الأيقونات
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        // لون العنوان
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        // إزالة الظل
        elevation: 0,
      ),

      // ==============================
      // ثيم الأزرار الرئيسية
      // ==============================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // لون الزر
          backgroundColor: AppColors.primary,
          // لون النص
          foregroundColor: AppColors.textPrimary,
          // الحجم الافتراضي
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          // شكل الزر — زوايا ناعمة
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // حجم الخط
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==============================
      // ثيم البطاقات
      // ==============================
      cardTheme: CardThemeData(
        // لون البطاقة
        color: AppColors.cardBackground,
        // إزالة الظل الافتراضي
        elevation: 0,
        // زوايا ناعمة
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        // مسافة خارجية
        margin: const EdgeInsets.all(8),
      ),

      // ==============================
      // ثيم النصوص
      // ==============================
      textTheme: const TextTheme(
        // عنوان كبير — اسم اللعبة
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 42,
          fontWeight: FontWeight.bold,
        ),
        // عنوان متوسط — اسم القالب
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        // نص السؤال
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        // نص عادي
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        // نص ثانوي
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
} 