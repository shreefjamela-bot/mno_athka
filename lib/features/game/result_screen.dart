// ==============================
// شاشة النتيجة النهائية
// اسم الملف: result_screen.dart
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/local_storage.dart' as AppStorage;

class ResultScreen extends StatefulWidget {
  final int totalPoints;
  final int correctAnswers;
  final int totalQuestions;
  final CategoryModel category;
  final int level;
  final String team1Name;
  final String team2Name;

  const ResultScreen({
    super.key,
    required this.totalPoints,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.category,
    required this.level,
    this.team1Name = 'الفريق الأول',
    this.team2Name = 'الفريق الثاني',
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {

  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;
  late Animation<double> _celebrationFade;

  @override
  void initState() {
    super.initState();
    _saveResults();
    _initAnimations();
  }

  void _initAnimations() {
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebrationScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _celebrationController, curve: Curves.elasticOut),
    );
    _celebrationFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeOut),
    );
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _saveResults() async {
    await AppStorage.LocalStorage.saveHighScore(widget.totalPoints);
    await AppStorage.LocalStorage.incrementTotalGames();
    await AppStorage.LocalStorage.addCorrectAnswers(widget.correctAnswers);
  }

  // ==============================
  // نحدد الفريق الفائز حسب النقاط
  // الفريق ١ يلعب أسئلة فردية
  // الفريق ٢ يلعب أسئلة زوجية
  // ==============================
  String _getWinnerName() {
    // نقسم الأسئلة — فردية للفريق ١، زوجية للفريق ٢
    int team1Points = 0;
    int team2Points = 0;

    for (int i = 0; i < widget.totalQuestions; i++) {
      if (i % 2 == 0) {
        team1Points += widget.totalPoints ~/ widget.totalQuestions;
      } else {
        team2Points += widget.totalPoints ~/ widget.totalQuestions;
      }
    }

    if (team1Points > team2Points) return widget.team1Name;
    if (team2Points > team1Points) return widget.team2Name;
    return 'تعادل';
  }

  Color _getLevelColor() {
    if (widget.level == 1) return AppColors.level1;
    if (widget.level == 2) return AppColors.level2;
    return AppColors.level3;
  }

  @override
  Widget build(BuildContext context) {
    final isLastLevel = widget.level == 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceMD),
          child: Column(
            children: [

              const SizedBox(height: AppSizes.spaceLG),

              // ==============================
              // أيقونة النتيجة مع أنيميشن
              // ==============================
              ScaleTransition(
                scale: _celebrationScale,
                child: FadeTransition(
                  opacity: _celebrationFade,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
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
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isLastLevel ? '🏆' : '🎯',
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceLG),

              // ==============================
              // رسالة مبروك للفريق الفائز
              // ==============================
              FadeTransition(
                opacity: _celebrationFade,
                child: Column(
                  children: [
                    if (isLastLevel) ...[
                      // رسالة خاصة للمستوى الثالث
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            AppColors.primaryLight,
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          '🎉 مبروك! 🎉',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الفريق الفائز',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontMD,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.glowGold,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Text(
                          _getWinnerName() == 'تعادل'
                              ? '🤝 تعادل!'
                              : '🏆 ${_getWinnerName()}',
                          style: const TextStyle(
                            color: AppColors.background,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ] else ...[
                      // رسالة للمستوى الأول والثاني
                      Text(
                        '${widget.category.emoji} ${widget.category.title}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontMD,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'انتهت الجولة',
                        style: TextStyle(
                          color: _getLevelColor(),
                          fontSize: AppSizes.fontXXL,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.spaceXXL),

              // ==============================
              // بطاقة النقاط والإحصائيات
              // ==============================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.spaceLG),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.cardBorderGold,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glowGold,
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // النقاط الكلية
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primary,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        '${widget.totalPoints}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Text(
                      'نقطة',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppSizes.fontLG,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceLG),

                    // خط فاصل
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.cardBorderGold,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceLG),

                    // إحصائيات
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
                          value:
                          '${widget.totalQuestions - widget.correctAnswers}',
                          color: AppColors.wrong,
                          emoji: '❌',
                        ),
                        _StatItem(
                          label: 'المستوى',
                          value: '${widget.level}',
                          color: _getLevelColor(),
                          emoji: '⭐',
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.spaceMD),

                    // ==============================
                    // أسماء الفريقين
                    // ==============================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('🔵',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(
                                widget.team1Name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'VS',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            children: [
                              const Text('🔴',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(
                                widget.team2Name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: AppSizes.spaceXXL),

              // زر العب مرة ثانية
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
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
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🔄 جولة جديدة',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: AppSizes.fontXL,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceMD),

              // زر الرئيسية
              GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorderGold),
                  ),
                  child: const Center(
                    child: Text(
                      '🏠 الشاشة الرئيسية',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppSizes.fontLG,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceLG),

            ],
          ),
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