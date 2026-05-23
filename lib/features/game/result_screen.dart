// ==============================
// شاشة النتيجة النهائية
// اسم الملف: result_screen.dart
// المكان: lib/features/game/
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/local_storage.dart';

// StatefulWidget عشان نحمّل البيانات المحفوظة
class ResultScreen extends StatefulWidget {
  final int totalPoints;
  final int correctAnswers;
  final int totalQuestions;
  final CategoryModel category;
  final int level;

  const ResultScreen({
    super.key,
    required this.totalPoints,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.category,
    required this.level,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  // ==============================
  // initState — يحفظ النقاط فور فتح الشاشة
  // ==============================
  @override
  void initState() {
    super.initState();
    _saveResults();
  }

  // ==============================
  // دالة حفظ النتائج
  // ==============================
  Future<void> _saveResults() async {
    // احفظ أعلى نقاط
    await LocalStorage.saveHighScore(widget.totalPoints);
    // زد عدد الجولات
    await LocalStorage.incrementTotalGames();
    // زد عدد الإجابات الصحيحة
    await LocalStorage.addCorrectAnswers(widget.correctAnswers);
  }

  String _getResultMessage() {
    final percentage = (widget.correctAnswers / widget.totalQuestions) * 100;
    if (percentage == 100) return '🏆 مثالي! أنت الأذكى!';
    if (percentage >= 80) return '🌟 ممتاز! أداء رائع!';
    if (percentage >= 60) return '👍 جيد! تقدر أحسن!';
    if (percentage >= 40) return '📚 مقبول! ذاكر أكثر!';
    return '💪 حاول مرة ثانية!';
  }

  Color _getResultColor() {
    final percentage = (widget.correctAnswers / widget.totalQuestions) * 100;
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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

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

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.spaceXL),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Column(
                children: [

                  Text(
                    '${widget.category.emoji} ${widget.category.title}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontLG,
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceLG),

                  Text(
                    '${widget.totalPoints}',
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
                  const Divider(color: AppColors.surfaceColor),
                  const SizedBox(height: AppSizes.spaceMD),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'صحيح',
                        value: '${widget.correctAnswers}',
                        color: AppColors.correct,
                        emoji: '✅',
                      ),
                      _StatItem(
                        label: 'خاطئ',
                        value: '${widget.totalQuestions - widget.correctAnswers}',
                        color: AppColors.wrong,
                        emoji: '❌',
                      ),
                      _StatItem(
                        label: 'المستوى',
                        value: '${widget.level}',
                        color: AppColors.primary,
                        emoji: '⭐',
                      ),
                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
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

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
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