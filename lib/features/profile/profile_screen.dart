// ==============================
// شاشة الملف الشخصي
// اسم الملف: profile_screen.dart
// المكان: lib/features/profile/
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      body: Padding(
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

            // إحصائيات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  emoji: '🏆',
                  label: 'أعلى نقاط',
                  value: '0',
                  color: AppColors.gold,
                ),
                _StatCard(
                  emoji: '🎮',
                  label: 'عدد الجولات',
                  value: '0',
                  color: AppColors.primary,
                ),
                _StatCard(
                  emoji: '✅',
                  label: 'إجابات صح',
                  value: '0',
                  color: AppColors.correct,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // رسالة مؤقتة
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