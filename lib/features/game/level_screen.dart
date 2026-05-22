// ==============================
// شاشة اختيار المستوى
// اسم الملف: level_screen.dart
// المكان: lib/features/game/
//
// اللاعب يختار المستوى قبل اللعب
// ١ = ٢٠٠ نقطة | ٢ = ٤٠٠ نقطة | ٣ = ٦٠٠ نقطة
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/category_model.dart';
import 'game_screen.dart';

class LevelScreen extends StatelessWidget {
  // الفئة اللي اختارها اللاعب
  final CategoryModel category;

  const LevelScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ==============================
      // الشريط العلوي
      // ==============================
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          category.title,
          style: const TextStyle(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ==============================
            // أيقونة الفئة
            // ==============================
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 80),
            ),

            const SizedBox(height: AppSizes.spaceLG),

            // اسم الفئة
            Text(
              category.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSizes.spaceSM),

            // وصف الفئة
            Text(
              category.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontLG,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // ==============================
            // عنوان اختيار المستوى
            // ==============================
            const Text(
              'اختر المستوى',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontLG,
              ),
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // ==============================
            // أزرار المستويات
            // ==============================

            // المستوى الأول
            _LevelButton(
              level: 1,
              title: 'المستوى الأول',
              points: '٢٠٠ نقطة',
              color: AppColors.level1,
              emoji: '🟢',
              category: category,
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // المستوى الثاني
            _LevelButton(
              level: 2,
              title: 'المستوى الثاني',
              points: '٤٠٠ نقطة',
              color: AppColors.level2,
              emoji: '🟡',
              category: category,
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // المستوى الثالث
            _LevelButton(
              level: 3,
              title: 'المستوى الثالث',
              points: '٦٠٠ نقطة',
              color: AppColors.level3,
              emoji: '🔴',
              category: category,
            ),

          ],
        ),
      ),
    );
  }
}

// ==============================
// زر المستوى
// ==============================
class _LevelButton extends StatelessWidget {
  final int level;
  final String title;
  final String points;
  final Color color;
  final String emoji;
  final CategoryModel category;

  const _LevelButton({
    required this.level,
    required this.title,
    required this.points,
    required this.color,
    required this.emoji,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // انتقل لشاشة اللعبة بالمستوى المختار
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(level: level),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [

            // أيقونة المستوى
            Text(
              emoji,
              style: const TextStyle(fontSize: 30),
            ),

            const SizedBox(width: AppSizes.spaceMD),

            // اسم المستوى
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // النقاط
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceMD,
                vertical: AppSizes.spaceSM,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Text(
                points,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontMD,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}