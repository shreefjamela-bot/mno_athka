// ==============================
// شاشة الملف الشخصي
// اسم الملف: profile_screen.dart
// المكان: lib/features/profile/
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/repositories/local_storage.dart';

// StatefulWidget عشان نحمّل البيانات من التخزين
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // ==============================
  // المتغيرات — البيانات المحفوظة
  // ==============================
  int _highScore = 0;
  int _totalGames = 0;
  int _correctAnswers = 0;

  // هل البيانات تحمّل الآن
  bool _isLoading = true;

  // ==============================
  // initState — يحمّل البيانات فور فتح الشاشة
  // ==============================
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==============================
  // دالة تحميل البيانات
  // ==============================
  Future<void> _loadData() async {
    // نجيب كل البيانات من التخزين
    final highScore = await LocalStorage.getHighScore();
    final totalGames = await LocalStorage.getTotalGames();
    final correctAnswers = await LocalStorage.getCorrectAnswers();

    // نحدّث الشاشة بالبيانات الجديدة
    setState(() {
      _highScore = highScore;
      _totalGames = totalGames;
      _correctAnswers = correctAnswers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'ملفي الشخصي',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
      // لما يحمّل — يعرض دائرة تحميل
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        child: Column(
          children: [

            const SizedBox(height: AppSizes.spaceLG),

            // صورة اللاعب
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(
                  color: AppColors.gold,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // اسم اللاعب
            const Text(
              'لاعب جديد',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // إحصائيات حقيقية من التخزين
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  emoji: '🏆',
                  label: 'أعلى نقاط',
                  value: '$_highScore',
                  color: AppColors.gold,
                ),
                _StatCard(
                  emoji: '🎮',
                  label: 'عدد الجولات',
                  value: '$_totalGames',
                  color: AppColors.primary,
                ),
                _StatCard(
                  emoji: '✅',
                  label: 'إجابات صح',
                  value: '$_correctAnswers',
                  color: AppColors.correct,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // رسالة تسجيل الدخول
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.spaceLG),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Column(
                children: [
                  Text('🔒', style: TextStyle(fontSize: 40)),
                  SizedBox(height: AppSizes.spaceSM),
                  Text(
                    'سجّل دخول لحفظ نقاطك',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppSizes.fontLG,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.spaceXS),
                  Text(
                    'في المرحلة القادمة نضيف تسجيل الدخول',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontMD,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: AppSizes.spaceXS),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSM,
            ),
          ),
        ],
      ),
    );
  }
}