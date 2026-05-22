// ==============================
// الملف الرئيسي للتطبيق
// اسم اللعبة: منو أذكى
// ==============================

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';

// ==============================
// نقطة البداية — أول شي يشتغل
// ==============================
void main() {
  runApp(const MnoAthkaApp());
}

// ==============================
// MnoAthkaApp — الكلاس الرئيسي
// ==============================
class MnoAthkaApp extends StatelessWidget {
  const MnoAthkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منو أذكى',
      debugShowCheckedModeBanner: false,
      // الثيم من ملف app_theme.dart
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

// ==============================
// HomeScreen — الشاشة الرئيسية
// ==============================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // اللون من AppColors مو مكتوب يدوياً
      backgroundColor: AppColors.background,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ==============================
            // أيقونة الكأس الذهبية
            // ==============================
            const Icon(
              Icons.emoji_events,
              size: 100,
              // اللون الذهبي من AppColors
              color: AppColors.gold,
            ),

            const SizedBox(height: 24),

            // ==============================
            // اسم اللعبة
            // ==============================
            const Text(
              'منو أذكى؟',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                // اللون من AppColors
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // ==============================
            // وصف اللعبة
            // ==============================
            const Text(
              'اختبر معلوماتك وتحدى أصدقاءك',
              style: TextStyle(
                fontSize: 16,
                // اللون الثانوي من AppColors
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 48),

            // ==============================
            // زر ابدأ اللعبة
            // ==============================
            Container(
              // تأثير Glow حول الزر
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // Glow بنفسجي من AppColors
                    color: AppColors.glowPrimary,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('قريباً — شاشة اللعبة!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // اللون من AppColors
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'ابدأ اللعبة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}