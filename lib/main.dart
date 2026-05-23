// ==============================
// الملف الرئيسي للتطبيق
// اسم اللعبة: منو أذكى
// ==============================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/supabase_config.dart';
import 'features/categories/categories_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/leaderboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.leaderboard, color: AppColors.primary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeaderboardScreen(),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [

            // ==============================
            // الجزء العلوي
            // ==============================
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // ==============================
                  // صورة شخص يفكر ويتأمل
                  // ==============================
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.background,
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.cardBorderGold,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glowGold,
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    // شخص يفكر
                    child: const Icon(
                      Icons.psychology_rounded,
                      size: 90,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==============================
                  // اسم اللعبة — سطرين
                  // ==============================
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'منو أذكى ؟',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // السطر الثاني من الاسم
                  const Text(
                    'واجهني ونشوف منو الأذكى',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      letterSpacing: 2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==============================
                  // جملة التحدي
                  // ==============================
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'تحدَّى الجميع ',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==============================
                  // جملة الترحيب
                  // ==============================
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cardBorderGold,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'استمتعوا بأوقاتكم مع لعبة " منو أذكى "\nلعبة المعلومات والتحدي اللي تجمع الأهل والأصدقاء',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ],
              ),
            ),

            // ==============================
            // الأزرار
            // ==============================
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // زر ابدأ اللعب
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesScreen(),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.glowGold,
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'ابدأ اللعب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // زر لوحة المتصدرين
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardScreen(),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.cardBorderGold,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.leaderboard,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'لوحة المتصدرين',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}