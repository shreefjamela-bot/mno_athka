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
  final int team1Points;
  final int team2Points;

  const ResultScreen({
    super.key,
    required this.totalPoints,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.category,
    required this.level,
    this.team1Name = 'الفريق الأول',
    this.team2Name = 'الفريق الثاني',
    this.team1Points = 0,
    this.team2Points = 0,
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
      CurvedAnimation(
          parent: _celebrationController, curve: Curves.easeOut),
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
  // الفريق الفائز حسب النقاط الحقيقية
  // ==============================
  String _getWinnerName() {
    if (widget.team1Points > widget.team2Points) return widget.team1Name;
    if (widget.team2Points > widget.team1Points) return widget.team2Name;
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
    final winner = _getWinnerName();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceMD),
          child: Column(
            children: [

              const SizedBox(height: AppSizes.spaceLG),

              // ==============================
              // أيقونة النتيجة
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
                          color: AppColors.cardBorderGold, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.glowGold,
                            blurRadius: 30,
                            spreadRadius: 5),
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
              // رسالة الفائز
              // ==============================
              FadeTransition(
                opacity: _celebrationFade,
                child: Column(
                  children: [
                    if (isLastLevel) ...[
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
                      const Text(
                        'الفريق الفائز',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
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
                                color: AppColors.glowGold, blurRadius: 20),
                          ],
                        ),
                        child: Text(
                          winner == 'تعادل'
                              ? '🤝 تعادل!'
                              : '🏆 $winner',
                          style: const TextStyle(
                            color: AppColors.background,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '${widget.category.emoji} ${widget.category.title}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
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
              // بطاقة نقاط الفريقين
              // ==============================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.spaceLG),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.cardBorderGold, width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.glowGold, blurRadius: 15),
                  ],
                ),
                child: Column(
                  children: [

                    // نقاط الفريقين
                    Row(
                      children: [

                        // الفريق ١
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: winner == widget.team1Name
                                  ? AppColors.correct.withOpacity(0.15)
                                  : AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: winner == widget.team1Name
                                    ? AppColors.correct
                                    : AppColors.cardBorder,
                                width: winner == widget.team1Name ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text('🔵',
                                    style: TextStyle(fontSize: 24)),
                                const SizedBox(height: 6),
                                Text(
                                  widget.team1Name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          AppColors.primaryLight,
                                          AppColors.primary,
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    '${widget.team1Points}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'نقطة',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                  ),
                                ),
                                if (winner == widget.team1Name)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('🏆 فائز',
                                        style: TextStyle(
                                          color: AppColors.correct,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // VS
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // الفريق ٢
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: winner == widget.team2Name
                                  ? AppColors.correct.withOpacity(0.15)
                                  : AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: winner == widget.team2Name
                                    ? AppColors.correct
                                    : AppColors.cardBorder,
                                width: winner == widget.team2Name ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text('🔴',
                                    style: TextStyle(fontSize: 24)),
                                const SizedBox(height: 6),
                                Text(
                                  widget.team2Name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          AppColors.primaryLight,
                                          AppColors.primary,
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    '${widget.team2Points}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'نقطة',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                  ),
                                ),
                                if (winner == widget.team2Name)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('🏆 فائز',
                                        style: TextStyle(
                                          color: AppColors.correct,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: AppSizes.spaceMD),

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

                    const SizedBox(height: AppSizes.spaceMD),

                    // إحصائيات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'الأسئلة',
                          value: '${widget.totalQuestions}',
                          color: AppColors.primary,
                          emoji: '❓',
                        ),
                        _StatItem(
                          label: 'المستوى',
                          value: '${widget.level}',
                          color: _getLevelColor(),
                          emoji: '⭐',
                        ),
                        _StatItem(
                          label: 'الفئة',
                          value: widget.category.emoji,
                          color: AppColors.secondary,
                          emoji: '',
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              const SizedBox(height: AppSizes.spaceXXL),

              // زر جولة جديدة
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
                          color: AppColors.glowGold, blurRadius: 15),
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
        Text(emoji.isEmpty ? value : emoji,
            style: const TextStyle(fontSize: 24)),
        const SizedBox(height: AppSizes.spaceXS),
        if (emoji.isNotEmpty)
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