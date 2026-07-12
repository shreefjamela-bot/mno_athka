// ==============================
// شاشة عجلة الحظ — Luxury Theme
// ==============================

import 'dart:math';
import 'package:flutter/material.dart';
import 'match_board_screen.dart';
import '../../data/models/category_model.dart';

const _gold = Color(0xFFC49830);
const _goldLight = Color(0xFFF0D060);
const _goldDark = Color(0xFF6B4A10);
const _bg = Color(0xFF080808);
const _cardBg = Color(0xFF0E0E0E);
const _goldText = Color(0xFF5A4820);

class LuckChallenge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String details;
  final Color color;

  const LuckChallenge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.details,
    required this.color,
  });
}

const List<LuckChallenge> kChallenges = [
  LuckChallenge(
    id: 'double_points',
    emoji: '⚡',
    title: 'نقطة مضاعفة',
    description: 'النقاط ×2 في أول جولة من المباراة',
    details: '📌 كيف يعمل:\n'
        '• جميع الأسئلة في الجولة الأولى فقط تُحتسب بالضعف\n'
        '• السؤال 200 يصير 400 ✦ السؤال 400 يصير 800 ✦ السؤال 600 يصير 1200\n'
        '• بعد الجولة الأولى ترجع النقاط عادية',
    color: Color(0xFFC49830),
  ),
  LuckChallenge(
    id: 'bonus_1000',
    emoji: '🌟',
    title: 'سؤال الألف',
    description: 'سؤال مفاجئ بـ 1000 نقطة عند أول سؤال 600',
    details: '📌 كيف يعمل:\n'
        '• يُطبّق عند أول سؤال مستوى 600 في المباراة\n'
        '• قيمته 1000 نقطة بدل 600\n'
        '• سؤال إضافي منفصل من فئة عشوائية',
    color: Color(0xFF9B59B6),
  ),
  LuckChallenge(
    id: 'normal',
    emoji: '🎲',
    title: 'لا تحدي',
    description: 'مباراة عادية بدون تحديات إضافية',
    details: '📌 كيف يعمل:\n'
        '• لا توجد تحديات إضافية\n'
        '• كل فريق يلعب بشكل عادي في فئاته\n'
        '• كل مستوى (200، 400، 600) يُلعب بسؤال واحد لكل فريق',
    color: Color(0xFF4A4A4A),
  ),
  LuckChallenge(
    id: 'time_pressure',
    emoji: '⏱️',
    title: 'ضغط الوقت',
    description: 'كل سؤال عنده 15 ثانية فقط',
    details: '📌 كيف يعمل:\n'
        '• وقت الإجابة يتقلص من 120 ثانية إلى 15 ثانية\n'
        '• ينطبق على جميع الأسئلة في المباراة\n'
        '• إذا انتهى الوقت بدون إجابة — لا نقاط للسؤال',
    color: Color(0xFFCC5500),
  ),
  LuckChallenge(
    id: 'double_bet',
    emoji: '⏫',
    title: 'الرهان',
    description: 'راهن بنقاطك في أسئلة المستوى 600',
    details: '📌 كيف يعمل:\n'
        '• يُطبّق فقط على أسئلة مستوى 600\n'
        '• قبل السؤال: كل فريق يختار كم نقطة يراهن بها\n'
        '• إذا أجاب صح → يكسب النقاط المراهن بها\n'
        '• إذا أجاب غلط → يخسر النقاط المراهن بها',
    color: Color(0xFF8B6914),
  ),
];

// ==============================
// رسام العجلة — Luxury
// ==============================
class WheelPainter extends CustomPainter {
  final double rotation;
  final int highlightedIndex;

  WheelPainter({required this.rotation, required this.highlightedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final count = kChallenges.length;
    final sweepAngle = 2 * pi / count;

    // رسم الشرائح
    for (int i = 0; i < count; i++) {
      final startAngle = rotation + i * sweepAngle;
      final challenge = kChallenges[i];
      final isHighlighted = i == highlightedIndex;

      // شريحة ممتلئة
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, true,
        Paint()
          ..color = isHighlighted
              ? challenge.color.withOpacity(0.95)
              : challenge.color.withOpacity(0.6)
          ..style = PaintingStyle.fill,
      );

      // حدود ذهبية
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, true,
        Paint()
          ..color = const Color(0xFF8B6914)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // الإيموجي
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.65;
      final textX = center.dx + cos(textAngle) * textRadius;
      final textY = center.dy + sin(textAngle) * textRadius;

      final tp = TextPainter(
        text: TextSpan(
          text: challenge.emoji,
          style: TextStyle(fontSize: isHighlighted ? 22 : 17),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(textX, textY);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // حلقة خارجية ذهبية
    canvas.drawCircle(center, radius,
        Paint()
          ..color = const Color(0xFFC49830)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);

    // مركز العجلة
    canvas.drawCircle(center, 30,
        Paint()..color = const Color(0xFF0A0A0A)..style = PaintingStyle.fill);
    canvas.drawCircle(center, 30,
        Paint()..color = const Color(0xFFC49830)..style = PaintingStyle.stroke..strokeWidth = 2);

    // نجمة في المركز
    _drawStar(canvas, center, 14, const Color(0xFFF0D060));
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
// شاشة عجلة الحظ
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

class _WheelScreenState extends State<WheelScreen> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;

  double _currentRotation = 0;
  int _resultIndex = 0;
  bool _isSpinning = false;
  bool _hasResult = false;
  bool _showDetails = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entranceFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _glowController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _hasResult = false;
      _showDetails = false;
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
    ).animate(CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic));

    _spinController.forward().then((_) {
      _currentRotation = _spinAnimation.value;
      final count = kChallenges.length;
      final sweepAngle = 2 * pi / count;
      final normalizedAngle = (-_currentRotation - pi / 2) % (2 * pi);
      final positiveAngle = normalizedAngle < 0 ? normalizedAngle + 2 * pi : normalizedAngle;
      _resultIndex = (positiveAngle / sweepAngle).floor() % count;

      setState(() {
        _isSpinning = false;
        _hasResult = true;
        _showDetails = true;
      });
    });
  }

  void _goToMatch() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MatchBoardScreen(
          team1Name: widget.team1Name,
          team2Name: widget.team2Name,
          team1Categories: widget.team1Categories,
          team2Categories: widget.team2Categories,
          challenge: _hasResult ? kChallenges[_resultIndex].id : 'normal',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = kChallenges[_resultIndex];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entranceFade,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // ===== هيدر =====
                  Row(
                    children: [
                      Expanded(child: Container(height: 0.5, color: _gold.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [_goldLight, _gold, _goldDark],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: const Text('عجلة الحظ',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Text('أدر العجلة لتحديد تحدي المباراة',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: _goldText.withOpacity(0.7),
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Container(height: 0.5, color: _gold.withOpacity(0.3))),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ===== العجلة =====
                  SizedBox(
                    height: 310,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // توهج خلفي
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (_, __) => Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_hasResult ? result.color : _gold)
                                      .withOpacity(0.15 * _glowAnimation.value),
                                  blurRadius: 50,
                                  spreadRadius: 15,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // العجلة
                        AnimatedBuilder(
                          animation: _isSpinning
                              ? _spinAnimation
                              : const AlwaysStoppedAnimation(0),
                          builder: (_, __) {
                            final rotation = _isSpinning
                                ? _spinAnimation.value
                                : _currentRotation;
                            return CustomPaint(
                              size: const Size(270, 270),
                              painter: WheelPainter(
                                rotation: rotation,
                                highlightedIndex: _hasResult && !_isSpinning ? _resultIndex : -1,
                              ),
                            );
                          },
                        ),

                        // مؤشر ذهبي
                        Positioned(
                          top: 2,
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (_, __) => Container(
                              width: 22,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_goldLight, _gold, _goldDark],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(11),
                                  bottomRight: Radius.circular(11),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withOpacity(0.5 * _glowAnimation.value),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A0E00), size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== النتيجة والأزرار =====
                  if (_hasResult) ...[

                    // بطاقة النتيجة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: result.color.withOpacity(0.6), width: 1),
                        boxShadow: [
                          BoxShadow(color: result.color.withOpacity(0.1), blurRadius: 20),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(result.emoji, style: const TextStyle(fontSize: 38)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(result.title,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: result.color,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(result.description,
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: _goldText.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (_showDetails) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              height: 0.5,
                              color: _gold.withOpacity(0.2),
                            ),
                            const SizedBox(height: 14),
                            Text(result.details,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: _goldText.withOpacity(0.8),
                                fontSize: 12,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // زر ابدأ المباراة
                    GestureDetector(
                      onTap: _goToMatch,
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3D2800),
                              Color(0xFFB8890A),
                              Color(0xFFE8C840),
                              Color(0xFFB8890A),
                              Color(0xFF3D2800),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(29),
                          boxShadow: [
                            BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 25, spreadRadius: 2),
                          ],
                        ),
                        child: const Center(
                          child: Text('ابدأ المباراة! 🎮',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A0E00),
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ] else ...[

                    // زر إدارة العجلة
                    GestureDetector(
                      onTap: _isSpinning ? null : _spin,
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (_, __) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: _isSpinning
                                ? LinearGradient(colors: [_cardBg, _cardBg])
                                : const LinearGradient(
                              colors: [
                                Color(0xFF3D2800),
                                Color(0xFFB8890A),
                                Color(0xFFE8C840),
                                Color(0xFFB8890A),
                                Color(0xFF3D2800),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(29),
                            border: _isSpinning
                                ? Border.all(color: _gold.withOpacity(0.3))
                                : null,
                            boxShadow: _isSpinning
                                ? []
                                : [
                              BoxShadow(
                                color: _gold.withOpacity(0.4 * _glowAnimation.value),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isSpinning ? 'تدور...' : 'أدر العجلة',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _isSpinning
                                    ? _gold.withOpacity(0.5)
                                    : const Color(0xFF1A0E00),
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // زر تخطي
                    GestureDetector(
                      onTap: _goToMatch,
                      child: Text(
                        'تخطي ← ابدأ بدون تحدي',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: _goldText.withOpacity(0.5),
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}