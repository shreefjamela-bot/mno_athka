// ==============================
// شاشة النتيجة النهائية
// اسم الملف: result_screen.dart
// ==============================

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/local_storage.dart' as AppStorage;

// ==============================
// رسام الكأس الذهبي
// ==============================
class TrophyPainter extends CustomPainter {
  final double shimmerProgress;

  TrophyPainter({required this.shimmerProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bodyPaint = Paint()
      ..color = const Color(0xFFD4AF6A)
      ..style = PaintingStyle.fill;

    final darkGold = Paint()
      ..color = const Color(0xFFC49B52)
      ..style = PaintingStyle.fill;

    final shimmerPaint = Paint()
      ..color = const Color(0xFFFFF8E7).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final handlePaint = Paint()
      ..color = const Color(0xFFD4AF6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    // الكأس body
    final bodyPath = Path();
    bodyPath.moveTo(cx - 45, cy - 80);
    bodyPath.lineTo(cx - 40, cy - 10);
    bodyPath.quadraticBezierTo(cx - 15, cy + 28, cx, cy + 32);
    bodyPath.quadraticBezierTo(cx + 15, cy + 28, cx + 40, cy - 10);
    bodyPath.lineTo(cx + 45, cy - 80);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // inner shadow
    final innerPath = Path();
    innerPath.moveTo(cx - 30, cy - 78);
    innerPath.lineTo(cx - 27, cy - 15);
    innerPath.quadraticBezierTo(cx - 10, cy + 18, cx, cy + 22);
    innerPath.quadraticBezierTo(cx + 10, cy + 18, cx + 27, cy - 15);
    innerPath.lineTo(cx + 30, cy - 78);
    innerPath.close();
    canvas.drawPath(innerPath, darkGold..color = const Color(0xFFC49B52).withOpacity(0.45));

    // rim أعلى الكأس
    final rimRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 47, cy - 88, 94, 12),
      const Radius.circular(6),
    );
    canvas.drawRRect(rimRect, darkGold..color = const Color(0xFFC49B52));

    // shine متحرك
    final shimmerY1 = cy - 78 + (shimmerProgress * 80);
    final shimmerY2 = cy - 78 + (shimmerProgress * 80) + 30;
    final clampedY2 = shimmerY2.clamp(cy - 78, cy + 22);

    if (shimmerY1 < cy + 22) {
      canvas.drawLine(
        Offset(cx - 26, shimmerY1),
        Offset(cx - 22, clampedY2),
        shimmerPaint,
      );
      canvas.drawLine(
        Offset(cx - 13, shimmerY1 - 4),
        Offset(cx - 10, (shimmerY2 - 4).clamp(cy - 78, cy + 22)),
        shimmerPaint..color = const Color(0xFFFFF8E7).withOpacity(0.28),
      );
    }

    // نجمة داخل الكأس
    _drawStar(canvas, Offset(cx, cy - 32), 13, const Color(0xFFB8962E).withOpacity(0.5));

    // الهاندلز (مقابض الكأس)
    final leftHandle = Path();
    leftHandle.moveTo(cx - 40, cy - 55);
    leftHandle.cubicTo(cx - 65, cy - 55, cx - 68, cy - 25, cx - 52, cy - 10);
    canvas.drawPath(leftHandle, handlePaint);

    final rightHandle = Path();
    rightHandle.moveTo(cx + 40, cy - 55);
    rightHandle.cubicTo(cx + 65, cy - 55, cx + 68, cy - 25, cx + 52, cy - 10);
    canvas.drawPath(rightHandle, handlePaint);

    // الساق
    final stemPath = Path();
    stemPath.moveTo(cx - 10, cy + 32);
    stemPath.lineTo(cx - 14, cy + 60);
    stemPath.lineTo(cx + 14, cy + 60);
    stemPath.lineTo(cx + 10, cy + 32);
    stemPath.close();
    canvas.drawPath(stemPath, bodyPaint..color = const Color(0xFFD4AF6A));

    // القاعدة
    final base1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 42, cy + 60, 84, 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(base1, bodyPaint..color = const Color(0xFFD4AF6A));

    final base2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 34, cy + 70, 68, 8),
      const Radius.circular(3),
    );
    canvas.drawRRect(base2, bodyPaint..color = const Color(0xFFB8962E));
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 4 * pi / 5) - pi / 2;
      final innerAngle = outerAngle + 2 * pi / 10;
      final outerX = center.dx + size * cos(outerAngle);
      final outerY = center.dy + size * sin(outerAngle);
      final innerX = center.dx + (size * 0.4) * cos(innerAngle);
      final innerY = center.dy + (size * 0.4) * sin(innerAngle);
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrophyPainter old) => old.shimmerProgress != shimmerProgress;
}

// ==============================
// رسام الألعاب النارية
// ==============================
class FireworkParticle {
  Offset position;
  Offset velocity;
  double life;
  double maxLife;
  Color color;
  double size;

  FireworkParticle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.size,
  });
}

class FireworksPainter extends CustomPainter {
  final List<FireworkParticle> particles;

  FireworksPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final opacity = (p.life / p.maxLife).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.size * opacity, paint);
    }
  }

  @override
  bool shouldRepaint(FireworksPainter old) => true;
}

// ==============================
// رسام أشعة الضوء
// ==============================
class LightRaysPainter extends CustomPainter {
  final double progress;

  LightRaysPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.38;

    final rays = [
      {'angle': -pi / 2, 'width': 38.0},
      {'angle': -pi / 2 - 0.35, 'width': 26.0},
      {'angle': -pi / 2 + 0.35, 'width': 26.0},
      {'angle': -pi / 2 - 0.72, 'width': 18.0},
      {'angle': -pi / 2 + 0.72, 'width': 18.0},
      {'angle': -pi / 2 - 1.1, 'width': 12.0},
      {'angle': -pi / 2 + 1.1, 'width': 12.0},
    ];

    for (final ray in rays) {
      final angle = ray['angle'] as double;
      final halfW = (ray['width'] as double) / 2;
      final length = size.height * 0.55 * progress;

      final leftAngle = angle - halfW * pi / 180;
      final rightAngle = angle + halfW * pi / 180;

      final path = Path();
      path.moveTo(cx, cy);
      path.lineTo(cx + cos(leftAngle) * length, cy + sin(leftAngle) * length);
      path.lineTo(cx + cos(rightAngle) * length, cy + sin(rightAngle) * length);
      path.close();

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFD4AF6A).withOpacity(0.22 * progress),
            const Color(0xFFD4AF6A).withOpacity(0.0),
          ],
          center: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(cx - length, cy - length, length * 2, length * 2))
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(LightRaysPainter old) => old.progress != progress;
}

// ==============================
// الشاشة الرئيسية
// ==============================
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

  // أنيميشن الكأس
  late AnimationController _trophyController;
  late Animation<double> _trophyScale;
  late Animation<double> _trophyFade;

  // أنيميشن الشيمر على الكأس
  late AnimationController _shimmerController;

  // أنيميشن أشعة الضوء
  late AnimationController _raysController;
  late Animation<double> _raysProgress;

  // أنيميشن الألعاب النارية
  late AnimationController _fireworksController;
  final List<FireworkParticle> _particles = [];
  final Random _random = Random();

  final List<Color> _fireworkColors = const [
    Color(0xFFD4AF6A),
    Color(0xFFFFF8E7),
    Color(0xFFB8962E),
    Color(0xFFFAD976),
    Color(0xFFEDD97A),
  ];

  @override
  void initState() {
    super.initState();
    _saveResults();
    _initAnimations();
  }

  void _initAnimations() {
    // --- كأس ---
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _trophyScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trophyController, curve: Curves.elasticOut),
    );
    _trophyFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trophyController, curve: Curves.easeOut),
    );

    // --- شيمر ---
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // --- أشعة ---
    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _raysProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _raysController, curve: Curves.easeOut),
    );

    // --- ألعاب نارية ---
    _fireworksController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);

    // تسلسل البداية
    _trophyController.forward().then((_) {
      _raysController.forward();
      _launchFirework();
      Future.delayed(const Duration(milliseconds: 400), _launchFirework);
      Future.delayed(const Duration(milliseconds: 750), _launchFirework);
      Future.delayed(const Duration(milliseconds: 1100), _launchFirework);
      Future.delayed(const Duration(milliseconds: 1500), _launchFirework);
      _fireworksController.repeat();
    });
  }

  void _launchFirework() {
    if (!mounted) return;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    final origin = Offset(
      _random.nextDouble() * screenW,
      _random.nextDouble() * screenH * 0.45,
    );

    final count = 28 + _random.nextInt(16);
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi + _random.nextDouble() * 0.3;
      final speed = 2.5 + _random.nextDouble() * 4.5;
      _particles.add(FireworkParticle(
        position: origin,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        life: 1.0,
        maxLife: 1.0,
        color: _fireworkColors[_random.nextInt(_fireworkColors.length)],
        size: 2.0 + _random.nextDouble() * 3.0,
      ));
    }
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (final p in _particles) {
        p.position += p.velocity;
        p.velocity = Offset(p.velocity.dx * 0.96, p.velocity.dy * 0.96 + 0.08);
        p.life -= 0.018;
      }
      _particles.removeWhere((p) => p.life <= 0);
    });
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _shimmerController.dispose();
    _raysController.dispose();
    _fireworksController.dispose();
    super.dispose();
  }

  Future<void> _saveResults() async {
    await AppStorage.LocalStorage.saveHighScore(widget.totalPoints);
    await AppStorage.LocalStorage.incrementTotalGames();
    await AppStorage.LocalStorage.addCorrectAnswers(widget.correctAnswers);
  }

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          // ==============================
          // طبقة ١: أشعة الضوء (الخلفية)
          // ==============================
          AnimatedBuilder(
            animation: _raysProgress,
            builder: (_, __) => CustomPaint(
              size: Size(size.width, size.height),
              painter: LightRaysPainter(progress: _raysProgress.value),
            ),
          ),

          // ==============================
          // طبقة ٢: الألعاب النارية
          // ==============================
          CustomPaint(
            size: Size(size.width, size.height),
            painter: FireworksPainter(particles: _particles),
          ),

          // ==============================
          // طبقة ٣: المحتوى
          // ==============================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.spaceMD),
              child: Column(
                children: [

                  const SizedBox(height: AppSizes.spaceLG),

                  // ==============================
                  // الكأس الذهبي
                  // ==============================
                  ScaleTransition(
                    scale: _trophyScale,
                    child: FadeTransition(
                      opacity: _trophyFade,
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (_, __) => SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: TrophyPainter(
                              shimmerProgress: _shimmerController.value,
                            ),
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
                    opacity: _trophyFade,
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
                                    color: AppColors.glowGold,
                                    blurRadius: 20),
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
                                color: AppColors.textSecondary,
                                fontSize: 14),
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
                        Row(
                          children: [
                            Expanded(child: _TeamCard(
                              name: widget.team1Name,
                              points: widget.team1Points,
                              emoji: '🔵',
                              isWinner: winner == widget.team1Name,
                            )),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('VS',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Expanded(child: _TeamCard(
                              name: widget.team2Name,
                              points: widget.team2Points,
                              emoji: '🔴',
                              isWinner: winner == widget.team2Name,
                            )),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spaceMD),
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.transparent,
                              AppColors.cardBorderGold,
                              Colors.transparent,
                            ]),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spaceMD),
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
                        border:
                        Border.all(color: AppColors.cardBorderGold),
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
        ],
      ),
    );
  }
}

// ==============================
// بطاقة الفريق
// ==============================
class _TeamCard extends StatelessWidget {
  final String name;
  final int points;
  final String emoji;
  final bool isWinner;

  const _TeamCard({
    required this.name,
    required this.points,
    required this.emoji,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWinner
            ? AppColors.correct.withOpacity(0.15)
            : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWinner ? AppColors.correct : AppColors.cardBorder,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            name,
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
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
            ).createShader(bounds),
            child: Text(
              '$points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text('نقطة',
              style: TextStyle(color: AppColors.primary, fontSize: 11)),
          if (isWinner)
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
    );
  }
}

// ==============================
// إحصائية صغيرة
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
        Text(emoji.isEmpty ? value : emoji,
            style: const TextStyle(fontSize: 24)),
        const SizedBox(height: AppSizes.spaceXS),
        if (emoji.isNotEmpty)
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              )),
        Text(label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSM,
            )),
      ],
    );
  }
}