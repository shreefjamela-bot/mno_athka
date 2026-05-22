// ==============================
// الملف الرئيسي للتطبيق
// اسم اللعبة: منو أذكى
// ==============================

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'features/categories/categories_screen.dart';
import 'features/profile/profile_screen.dart';

void main() {
  runApp(const MnoAthkaApp());
}

class MnoAthkaApp extends StatelessWidget {
  const MnoAthkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منو أذكى',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ==============================
      // شريط علوي مع زر الملف الشخصي
      // ==============================
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // زر الملف الشخصي — يمين
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.textPrimary,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // أيقونة الكأس الذهبية
            const Icon(
              Icons.emoji_events,
              size: 100,
              color: AppColors.gold,
            ),

            const SizedBox(height: 24),

            // اسم اللعبة
            const Text(
              'منو أذكى؟',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // وصف اللعبة
            const Text(
              'اختبر معلوماتك وتحدى أصدقاءك',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 48),

            // زر ابدأ اللعبة
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glowPrimary,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
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