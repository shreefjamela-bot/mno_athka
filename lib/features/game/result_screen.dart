// ==============================
// شاشة النتيجة النهائية
// اسم الملف: result_screen.dart
// المكان: lib/features/game/
//
// تظهر بعد انتهاء كل الأسئلة
// تعرض النقاط والإحصائيات
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/category_model.dart';

class ResultScreen extends StatelessWidget {
  // النقاط الكلية
  final int totalPoints;

  // عدد الإجابات الصحيحة
  final int correctAnswers;

  // عدد الأسئلة الكلي
  final int totalQuestions;

  // الفئة اللي لعب فيها
  final CategoryModel category;

  // المستوى
  final int level;

  const ResultScreen({
    super.key,
    required this.totalPoints,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.category,
    required this.level,
  });

  // ==============================
  // دالة تحدد رسالة النتيجة
  // حسب النسبة المئوية
  // ==============================
  String _getResultMessage() {
    // نسبة الإجابات الصحيحة
    final percentage = (correctAnswers / totalQuestions) * 100;

    if (percentage == 100) return '🏆 مثالي! أنت الأذكى!';
    if (percentage >= 80) return '🌟 ممتاز! أداء رائع!';
    if (percentage >= 60) return '👍 جيد! تقدر أحسن!';
    if (percentage >= 40) return '📚 مقبول! ذاكر أكثر!';
    return '💪 حاول مرة ثانية!';
  }

  // ==============================
  // دالة تحدد لون النتيجة
  // ==============================
  Color _getResultColor() {
    final percentage = (correctAnswers / totalQuestions) * 100;

    if (percentage == 100) return AppColors.gold;
    if (percentage >= 80) return AppColors.correct;
    if (percentage >= 60) return AppColors.secondary;
    if (percentage >= 40) return AppColors.level2;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ==============================
      // الشريط العلوي
      // ==============================
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'النتيجة النهائية',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // إخفاء زر الرجوع
        automaticallyImplyLeading: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ==============================
            // رسالة النتيجة
            // ==============================
            Text(
              _getResultMessage(),
              style: TextStyle(
                color: _getResultColor(),
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // ==============================
            // بطاقة الإحصائيات
            // ==============================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.spaceXL),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1,
                ),
              ),
              child: Column(
                children: [

                  // اسم الفئة
                  Text(
                    '${category.emoji} ${category.title}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontLG,
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceLG),

                  // النقاط الكلية
                  Text(
                    '$totalPoints',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'نقطة',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: AppSizes.fontXL,
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceLG),

                  // خط فاصل
                  const Divider(color: AppColors.surfaceColor),

                  const SizedBox(height: AppSizes.spaceMD),

                  // إحصائيات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      // الإجابات الصحيحة
                      _StatItem(
                        label: 'صحيح',
                        value: '$correctAnswers',
                        color: AppColors.correct,
                        emoji: '✅',
                      ),

                      // الإجابات الخاطئة
                      _StatItem(
                        label: 'خاطئ',
                        value: '${totalQuestions - correctAnswers}',
                        color: AppColors.wrong,
                        emoji: '❌',
                      ),

                      // المستوى
                      _StatItem(
                        label: 'المستوى',
                        value: '$level',
                        color: AppColors.primary,
                        emoji: '⭐',
                      ),

                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // ==============================
            // زر العب مرة ثانية
            // ==============================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ارجع لشاشة المستوى
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spaceMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                child: const Text(
                  '🔄 العب مرة ثانية',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // ==============================
            // زر الرئيسية
            // ==============================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // ارجع للشاشة الرئيسية
                  Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spaceMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                child: const Text(
                  '🏠 الشاشة الرئيسية',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppSizes.fontXL,
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

// ==============================
// ويدجت الإحصائية الواحدة
// ==============================
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String emoji;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}