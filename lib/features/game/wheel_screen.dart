// ==============================
// شاشة عجلة الحظ
// اسم الملف: wheel_screen.dart
// المكان: lib/features/game/
// ==============================

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'match_board_screen.dart';
import '../../data/models/category_model.dart';

// ==============================
// نموذج التحدي
// ==============================
class LuckChallenge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const LuckChallenge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}

const List<LuckChallenge> kChallenges = [
  LuckChallenge(
    id: 'double_points',
    emoji: '⚡',
    title: 'نقطة مضاعفة',
    description: 'النقاط ×2 في أول جولة من المباراة',
    color: Color(0xFFFFD700),
  ),
  LuckChallenge(
    id: 'bonus_1000',
    emoji: '🌟',
    title: 'سؤال الألف',
    description: 'سؤال مفاجئ بـ 1000 نقطة في منتصف المباراة',
    color: Color(0xFF9B59B6),
  ),
  LuckChallenge(
    id: 'normal',
    emoji: '🎲',
    title: 'حظ عادي',
    description: 'لا تحديات — العبوا بشكل عادي',
    color: Color(0xFF6B6B6B),
  ),
  LuckChallenge(
    id: 'time_pressure',
    emoji: '⏱️',
    title: 'ضغط الوقت',
    description: 'كل سؤال عنده 15 ثانية فقط بدل 120',
    color: Color(0xFFFF6B35),
  ),
  LuckChallenge(
    id: 'random_start',
    emoji: '🔀',
    title: 'ترتيب عشوائي',
    description: 'من يبدأ يتحدد بالعشوائي',
    color: Color(0xFF1A5F8A),
  ),
  LuckChallenge(
    id: 'double_question',
    emoji: '💥',
    title: 'سؤال مزدوج',
    description: 'أول سؤال الفريقين يتنافسون — الأسرع ياخذ النقاط',
    color: Color(0xFF8B2635),
  ),
  LuckChallenge(
    id: 'swap_categories',
    emoji: '🔁',
    title: 'عكس الأدوار',
    description: 'فريق 1 يجيب عن فئات فريق 2 والعكس في الجولة الأولى',
    color: Color(0xFF2D7A5F),
  ),
  LuckChallenge(
    id: 'double_bet',
    emoji: '⏫',
    title: 'مضاعفة الرهان',
    description: 'قبل كل سؤال الفريق يقرر — يراهن بنقاطه أو لا',
    color: Color(0xFFD4AF6A),
  ),
];

// ==============================
// رسام العجلة
// ==============================
class WheelPainter extends CustomPainter {
  final double rotation;
  final int highlightedIndex;

  WheelPainter({required this.rotation, required this.highlightedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final count = kChallenges.length;
    final sweepAngle = 2 * pi / count;

    for (int i = 0; i < count; i++) {
      final startAngle = rotation + i * sweepAngle;
      final challenge = kChallenges[i];
      final isHighlighted = i == highlightedIndex;

      final paint = Paint()
        ..color = isHighlighted
            ? challenge.color
            : challenge.color.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = const Color(0xFF0D0D0F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.65;
      final textX = center.dx + cos(textAngle) * textRadius;
      final textY = center.dy + sin(textAngle) * textRadius;

      final tp = TextPainter(
        text: TextSpan(
          text: challenge.emoji,
          style: TextStyle(fontSize: isHighlighted ? 22 : 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(textX, textY);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // دائرة الوسط
    canvas.drawCircle(center, 28,
        Paint()..color = const Color(0xFF0D0D0F)..style = PaintingStyle.fill);
    canvas.drawCircle(
        center,
        28,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    _drawStar(canvas, center, 14, AppColors.primary);
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
      if (i == 0) path.moveTo(outerX, outerY);
      else path.lineTo(outerX, outerY);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WheelPainter old) =>
      old.rotation != rotation || old.highlightedIndex != highlightedIndex;
}

// ==============================
// الشاشة الرئيسية
// ==============================
class WheelScreen extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  final List<CategoryModel> team1Categories;
  final List<CategoryModel> team2Categories;

  const WheelScreen({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.team1Categories,
    required this.team2Categories,
  });

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen>
    with TickerProviderStateMixin {

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  double _currentRotation = 0;
  int _resultIndex = 0;
  bool _isSpinning = false;
  bool _hasResult = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _hasResult = false;
    });

    final extraSpins = 5 + _random.nextInt(5);
    final finalAngle = _random.nextDouble() * 2 * pi;
    final totalRotation = extraSpins * 2 * pi + finalAngle;

    _spinController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + _random.nextInt(1000)),
    );

    _spinAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + totalRotation,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.forward().then((_) {
      _currentRotation = _spinAnimation.value;
      final count = kChallenges.length;
      final sweepAngle = 2 * pi / count;
      final normalizedAngle = (-_currentRotation - pi / 2) % (2 * pi);
      final positiveAngle =
      normalizedAngle < 0 ? normalizedAngle + 2 * pi : normalizedAngle;
      _resultIndex = (positiveAngle / sweepAngle).floor() % count;

      setState(() {
        _isSpinning = false;
        _hasResult = true;
      });
    });
  }

  void _goToMatch() {
    final challenge = kChallenges[_resultIndex];

    // عكس الأدوار — نبدل الفئات
    final t1 = challenge.id == 'swap_categories'
        ? widget.team2Categories
        : widget.team1Categories;
    final t2 = challenge.id == 'swap_categories'
        ? widget.team1Categories
        : widget.team2Categories;

    // ترتيب عشوائي — نبدل الفريقين
    final bool swap = challenge.id == 'random_start' && _random.nextBool();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MatchBoardScreen(
          team1Name: swap ? widget.team2Name : widget.team1Name,
          team2Name: swap ? widget.team1Name : widget.team2Name,
          team1Categories: swap ? t2 : t1,
          team2Categories: swap ? t1 : t2,
          challenge: challenge.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = kChallenges[_resultIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // الهيدر
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      '🎡 عجلة الحظ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'أدر العجلة لتحديد تحدي المباراة',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // العجلة
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_hasResult)
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (_, __) => Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: result.color
                                  .withOpacity(0.3 * _glowAnimation.value),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                  AnimatedBuilder(
                    animation: _isSpinning
                        ? _spinAnimation
                        : const AlwaysStoppedAnimation(0),
                    builder: (_, __) {
                      final rotation = _isSpinning
                          ? _spinAnimation.value
                          : _currentRotation;
                      return CustomPaint(
                        size: const Size(260, 260),
                        painter: WheelPainter(
                          rotation: rotation,
                          highlightedIndex:
                          _hasResult && !_isSpinning ? _resultIndex : -1,
                        ),
                      );
                    },
                  ),

                  // المؤشر
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.glowGold, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.arrow_drop_down,
                          color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // النتيجة والأزرار
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hasResult) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: result.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: result.color, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: result.color.withOpacity(0.2),
                                blurRadius: 20),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(result.emoji,
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.title,
                                    style: TextStyle(
                                      color: result.color,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    result.description,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _goToMatch,
                          child: const Text(
                            'ابدأ المباراة! 🎮',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: _isSpinning ? null : _spin,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isSpinning
                                  ? [Colors.grey, Colors.grey]
                                  : [
                                AppColors.primaryDark,
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isSpinning
                                ? []
                                : [
                              BoxShadow(
                                  color: AppColors.glowGold,
                                  blurRadius: 20),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isSpinning ? '🎡 تدور...' : '🎡 أدر العجلة',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _goToMatch,
                        child: const Text(
                          'تخطي ← ابدأ بدون تحدي',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ),
                    ],
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