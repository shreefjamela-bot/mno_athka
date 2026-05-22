// ==============================
// ملف الألوان الثابتة للعبة
// اسم الملف: app_colors.dart
// المكان: lib/core/constants/
//
// كل ألوان اللعبة في مكان واحد
// لو أبيت تغير أي لون — غيره هنا فقط
// ==============================

import 'package:flutter/material.dart';

// abstract = كلاس ما ينشأ منه object
// فقط نستخدمه للوصول للألوان مباشرة
abstract class AppColors {

  // ==============================
  // ألوان الخلفية
  // ==============================

  // الخلفية الرئيسية — أسود فخم
  static const Color background = Color(0xFF0A0A0F);

  // خلفية البطاقات — أسود أفتح شوي
  static const Color cardBackground = Color(0xFF12121A);

  // خلفية ثانوية للعناصر
  static const Color surfaceColor = Color(0xFF1A1A2E);

  // ==============================
  // الألوان الأساسية
  // ==============================

  // البنفسجي الكهربائي — هوية اللعبة
  static const Color primary = Color(0xFF7C3AED);

  // البنفسجي الفاتح — للتأثيرات
  static const Color primaryLight = Color(0xFF9D5FF3);

  // البنفسجي الداكن — عند الضغط
  static const Color primaryDark = Color(0xFF5B21B6);

  // ==============================
  // اللون الثاني — السماوي النيون
  // ==============================

  // السماوي الأساسي
  static const Color secondary = Color(0xFF00D4FF);

  // السماوي عند الضغط على الزر
  static const Color secondaryDark = Color(0xFF06B6D4);

  // ==============================
  // لون النقاط والجوائز
  // ==============================

  // الذهبي الفاخر — للنقاط والتاج
  static const Color gold = Color(0xFFFFD700);

  // الذهبي الداكن — للتفاصيل
  static const Color goldDark = Color(0xFFB8860B);

  // ==============================
  // ألوان النصوص
  // ==============================

  // الأبيض — النصوص الرئيسية
  static const Color textPrimary = Color(0xFFFFFFFF);

  // الرمادي الفاتح — النصوص الثانوية
  static const Color textSecondary = Color(0xFF94A3B8);

  // الرمادي الداكن — النصوص الخافتة
  static const Color textHint = Color(0xFF475569);

  // ==============================
  // ألوان الإجابات
  // ==============================

  // الإجابة الصحيحة — أخضر
  static const Color correct = Color(0xFF22C55E);

  // الإجابة الخاطئة — أحمر
  static const Color wrong = Color(0xFFEF4444);

  // الإجابة المحددة — أصفر
  static const Color selected = Color(0xFFF59E0B);

  // ==============================
  // ألوان المستويات
  // ==============================

  // المستوى الأول — ٢٠٠ نقطة — أخضر
  static const Color level1 = Color(0xFF22C55E);

  // المستوى الثاني — ٤٠٠ نقطة — برتقالي
  static const Color level2 = Color(0xFFF97316);

  // المستوى الثالث — ٦٠٠ نقطة — أحمر
  static const Color level3 = Color(0xFFEF4444);

  // ==============================
  // تأثير Glow للأزرار
  // ==============================

  // Glow البنفسجي — حول الزر الأساسي
  static const Color glowPrimary = Color(0x557C3AED);

  // Glow السماوي — حول الزر الثاني
  static const Color glowSecondary = Color(0x5500D4FF);

  // Glow الذهبي — حول النقاط
  static const Color glowGold = Color(0x55FFD700);
}