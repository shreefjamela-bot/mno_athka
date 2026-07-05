// ==============================
// الملف الرئيسي للتطبيق
// اسم اللعبة: منو أذكى
// ==============================

import 'dart:async';
import 'dart:math';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/supabase_config.dart';
import 'features/game/draft_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/leaderboard_screen.dart';
import 'features/suggestions_screen.dart';
import 'features/user_questions_screen.dart';
import 'features/weekly_challenge_screen.dart';
import 'features/custom_categories_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const MnoAthkaApp());
}

class MnoAthkaApp extends StatelessWidget {
  const MnoAthkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منو أذكى',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

const List<String> _dailyFacts = [
  '🧠 الدماغ البشري يولّد ما يكفي من الكهرباء لإضاءة مصباح صغير',
  '🌊 المحيطات تغطي أكثر من 70% من سطح الأرض',
  '⚡ البرق يضرب الأرض نحو 100 مرة في الثانية الواحدة',
  '🦋 الفراشة تتذوق الطعام بأقدامها',
  '🌙 القمر يبتعد عن الأرض بمقدار 3.8 سم كل عام',
  '🐘 الفيل هو الحيوان الوحيد الذي لا يستطيع القفز',
  '💧 جسم الإنسان يتكون من 60% ماء',
  '🌍 الصين هي أكثر دول العالم سكاناً بأكثر من 1.4 مليار نسمة',
  '🦁 الأسد ينام نحو 20 ساعة يومياً',
  '🍯 العسل لا يفسد أبداً — وُجد عسل في المقابر الفرعونية لا يزال صالحاً',
  '🌸 اليابان لديها أكثر من 6800 جزيرة',
  '🎵 الموسيقى تُقلل من القلق وتُحسّن المزاج علمياً',
  '🦜 ببغاء الإفريقي الرمادي يمكنه تعلم أكثر من 1000 كلمة',
  '🏔️ جبل إيفرست ينمو بمقدار 4 ملم كل عام',
  '🐬 الدلافين تنام بنصف دماغها فقط لتبقى يقظة',
  '☀️ الشمس تشكّل 99.86% من كتلة المجموعة الشمسية',
  '🌿 الغابات الاستوائية تنتج 20% من أكسجين الأرض',
  '🦴 جسم الإنسان البالغ يحتوي على 206 عظمة',
  '🐙 الأخطبوط لديه ثلاثة قلوب ودمه أزرق اللون',
  '🎯 المخ البشري يعالج الصور في أقل من 13 ميلي ثانية',
  '🌺 هناك أكثر من 400,000 نوع من النباتات الزهرية في العالم',
  '🦅 النسر يمكنه رؤية فريسته من ارتفاع 3 كيلومترات',
  '💎 الماس هو أصلب مادة طبيعية على وجه الأرض',
  '🌋 هناك أكثر من 1500 بركان نشط حول العالم',
];

String _getDailyFact() {
  final dayOfYear =
      DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return _dailyFacts[dayOfYear % _dailyFacts.length];
}

// ==============================
// رسام النجوم
// ==============================
class _StarsPainter extends CustomPainter {
  final double progress;
  final List<Offset> stars;
  final List<double> sizes;
  final List<double> twinkleOffsets;

  _StarsPainter({
    required this.progress,
    required this.stars,
    required this.sizes,
    required this.twinkleOffsets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < stars.length; i++) {
      final twinkleSpeed = i % 3 == 0 ? 3.0 : i % 3 == 1 ? 1.5 : 0.8;
      final opacity =
      (sin(progress * 2 * pi * twinkleSpeed + twinkleOffsets[i]) * 0.4 + 0.5)
          .clamp(0.1, 1.0);

      if (sizes[i] > 1.5) {
        final haloPaint = Paint()
          ..color = const Color(0xFF4FC3F7).withOpacity(opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(
          Offset(stars[i].dx * size.width, stars[i].dy * size.height),
          sizes[i] * 3,
          haloPaint,
        );
      }

      final color = i % 5 == 0
          ? const Color(0xFFFFD700)
          : i % 5 == 1
          ? const Color(0xFF4FC3F7)
          : Colors.white;

      canvas.drawCircle(
        Offset(stars[i].dx * size.width, stars[i].dy * size.height),
        sizes[i],
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.progress != progress;
}

// ==============================
// ويدجت الفيديو — HTML Web
// ==============================
class _VideoCard extends StatefulWidget {
  const _VideoCard();

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      _registered = true;
      ui.platformViewRegistry.registerViewFactory(
        'mno-video-player',
            (int viewId) {
          final video = html.VideoElement()
            ..src =
                'https://qfvobkacbxeyaybfcuju.supabase.co/storage/v1/object/public/questions-media/wajha.mp4'
            ..autoplay = true
            ..loop = true
            ..muted = true
            ..controls = true
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover'
            ..style.borderRadius = '20px'
            ..style.background = 'transparent';
          return video;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Text('🎬', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFD4A843), Color(0xFF00D4FF)],
                ).createShader(bounds),
                child: const Text(
                  'تعرف على اللعبة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const HtmlElementView(viewType: 'mno-video-player'),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '🔊 اضغط على الفيديو لتشغيل الصوت',
          style: TextStyle(color: Color(0xFF4A5A7A), fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ==============================
// ويدجت اللوغو
// ==============================
class _LogoWidget extends StatelessWidget {
  final double glowValue;
  const _LogoWidget({required this.glowValue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // توهج خلفي
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A843).withOpacity(0.15 * glowValue),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          // الإطار الإسلامي
          CustomPaint(
            size: const Size(140, 180),
            painter: _IslamicFramePainter(glowValue),
          ),

          // المحتوى داخل الإطار
          Positioned(
            top: 30,
            child: Column(
              children: [
                // أيقونة الدماغ
                const Text('🧠', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 6),
                // كلمة منو
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFD4A843), Color(0xFFF5DFA0), Color(0xFFD4A843)],
                  ).createShader(bounds),
                  child: const Text(
                    'منو',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                // كلمة أذكى
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF7A5200),
                      Color(0xFFD4A843),
                      Color(0xFFF5DFA0),
                      Color(0xFFFFD700),
                      Color(0xFFD4A843),
                      Color(0xFF7A5200),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'أذكى؟',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                // سطر صغير
                const Text(
                  'مسابقات وتحديات ذكية',
                  style: TextStyle(
                    color: Color(0xFF8BA0C8),
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicFramePainter extends CustomPainter {
  final double glow;
  _IslamicFramePainter(this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    final goldStroke = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0xFF7A5200),
          Color(0xFFD4A843),
          Color(0xFFF5DFA0),
          Color(0xFFD4A843),
          Color(0xFF7A5200),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final goldFill = Paint()
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.fill;

    // قوس إسلامي في الأعلى
    final archPath = Path()
      ..moveTo(10, size.height - 10)
      ..lineTo(10, size.height * 0.45)
      ..quadraticBezierTo(10, size.height * 0.15, cx, 10)
      ..quadraticBezierTo(size.width - 10, size.height * 0.15, size.width - 10, size.height * 0.45)
      ..lineTo(size.width - 10, size.height - 10);
    canvas.drawPath(archPath, goldStroke);

    // قاعدة
    canvas.drawLine(
      Offset(0, size.height - 10),
      Offset(size.width, size.height - 10),
      goldStroke..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(8, size.height - 4),
      Offset(size.width - 8, size.height - 4),
      Paint()
        ..color = const Color(0xFFD4A843).withOpacity(0.4)
        ..strokeWidth = 1,
    );

    // نقاط الزوايا
    canvas.drawCircle(Offset(0, size.height - 10), 3, goldFill);
    canvas.drawCircle(Offset(size.width, size.height - 10), 3, goldFill);

    // نجمة في القمة
    _drawStar(canvas, Offset(cx, 4), 7, goldFill..color = const Color(0xFFF5DFA0));
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * (pi / 180);
      final radius = i.isEven ? r : r * 0.4;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IslamicFramePainter old) => old.glow != glow;
}

// ==============================
// الشاشة الرئيسية
// ==============================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _starsController;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;
  int? _pressedButton;

  final _random = Random(42);
  late final List<Offset> _stars;
  late final List<double> _starSizes;
  late final List<double> _twinkleOffsets;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(70, (_) => Offset(_random.nextDouble(), _random.nextDouble()));
    _starSizes = List.generate(70, (_) => _random.nextDouble() * 2.2 + 0.4);
    _twinkleOffsets = List.generate(70, (_) => _random.nextDouble() * 2 * pi);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entranceFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _starsController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
    required int index,
  }) {
    final isPressed = _pressedButton == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedButton = index),
      onTapUp: (_) {
        setState(() => _pressedButton = null);
        onTap();
      },
      onTapCancel: () => setState(() => _pressedButton = null),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (_, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: double.infinity,
          height: 58,
          transform: Matrix4.identity()..translate(0.0, isPressed ? 3.0 : 0.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7A5200),
                Color(0xFFD4A843),
                Color(0xFFF5DFA0),
                Color(0xFFFFEA80),
                Color(0xFFF5DFA0),
                Color(0xFFD4A843),
                Color(0xFF7A5200),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: isPressed
                ? []
                : [
              BoxShadow(
                color: const Color(0xFFD4A843).withOpacity(0.7 * _glowAnimation.value),
                blurRadius: 35,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFFF0C855).withOpacity(0.3),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('▶', style: TextStyle(fontSize: 18, color: Color(0xFF3A2800))),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A1A00),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonButton({
    required String emoji,
    required String label,
    required VoidCallback onTap,
    required int index,
    required Color color,
  }) {
    final isPressed = _pressedButton == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedButton = index),
      onTapUp: (_) {
        setState(() => _pressedButton = null);
        onTap();
      },
      onTapCancel: () => setState(() => _pressedButton = null),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (_, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: double.infinity,
          height: 52,
          transform: Matrix4.identity()..translate(0.0, isPressed ? 2.0 : 0.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: color.withOpacity(0.55 + 0.35 * _glowAnimation.value),
              width: 1.8,
            ),
            boxShadow: isPressed
                ? []
                : [
              BoxShadow(
                color: color.withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepthCard({required Widget child}) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628).withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.18 + 0.1 * _glowAnimation.value),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A8FE3).withOpacity(0.1 * _glowAnimation.value),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // خلفية
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF050F2E),
                    Color(0xFF081428),
                    Color(0xFF040D20),
                    Color(0xFF020810),
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            top: -100,
            left: -80,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1565C0).withOpacity(0.15 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            right: -80,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0D47A1).withOpacity(0.12 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // نجوم
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _starsController,
              builder: (_, __) => CustomPaint(
                painter: _StarsPainter(
                  progress: _starsController.value,
                  stars: _stars,
                  sizes: _starSizes,
                  twinkleOffsets: _twinkleOffsets,
                ),
              ),
            ),
          ),

          // المحتوى
          SafeArea(
            child: FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _entranceSlide,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            _buildIconBtn(
                              icon: Icons.leaderboard_rounded,
                              color: const Color(0xFFD4A843),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                              ),
                            ),
                            const Spacer(),
                            _buildIconBtn(
                              icon: Icons.person_outline_rounded,
                              color: const Color(0xFF00D4FF),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // البطاقة الزجاجية
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1E3D).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFF00D4FF).withOpacity(0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565C0).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [

                              // اللوغو
                              AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (_, __) => _LogoWidget(glowValue: _glowAnimation.value),
                              ),

                              const SizedBox(height: 8),

                              // سطر تحت اللوغو
                              Text(
                                'تحدى أصحابك الآن!',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: const Color(0xFF00D4FF).withOpacity(0.9),
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 28),

                              _buildPrimaryButton(
                                label: 'ابدأ اللعب',
                                index: 0,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DraftScreen()),
                                ),
                              ),

                              const SizedBox(height: 14),

                              _buildNeonButton(
                                emoji: '🏆',
                                label: 'التحدي الأسبوعي',
                                index: 1,
                                color: const Color(0xFF00D4FF),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const WeeklyChallengeScreen()),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildNeonButton(
                                emoji: '✍️',
                                label: 'أضف سؤالك',
                                index: 2,
                                color: const Color(0xFF00E676),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const UserQuestionsScreen()),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildNeonButton(
                                emoji: '🗂️',
                                label: 'فئتك الخاصة',
                                index: 3,
                                color: const Color(0xFFD4A843),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CustomCategoriesScreen()),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildNeonButton(
                                emoji: '💬',
                                label: 'اقتراحاتك تهمنا',
                                index: 4,
                                color: const Color(0xFF7C4DFF),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SuggestionsScreen()),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // فيديو تعريفي
                        const _VideoCard(),

                        const SizedBox(height: 20),

                        // بطاقة التحدي
                        const _WeeklyChallengeCard(),

                        const SizedBox(height: 20),

                        // كل يوم معلومة
                        _buildDepthCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4A843).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFD4A843), width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('💡', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 6),
                                    Text(
                                      'كل يوم معلومة',
                                      style: TextStyle(
                                        color: Color(0xFFD4A843),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getDailyFact(),
                                style: const TextStyle(
                                  color: Color(0xFFF0F4FF),
                                  fontSize: 15,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildDepthCard(
                          child: const Text(
                            'استمتعوا بأوقاتكم مع لعبة " منو أذكى "\nلعبة المعلومات والتحدي اللي تجمع الأهل والأصدقاء',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8BA0C8),
                              height: 1.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (_, __) => Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628).withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.4 + 0.2 * _glowAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2 * _glowAnimation.value),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

// ==============================
// بطاقة التحدي الأسبوعي
// ==============================
class _WeeklyChallengeCard extends StatefulWidget {
  const _WeeklyChallengeCard();

  @override
  State<_WeeklyChallengeCard> createState() => _WeeklyChallengeCardState();
}

class _WeeklyChallengeCardState extends State<_WeeklyChallengeCard>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _challenge;
  bool _isLoading = true;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _load();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await Supabase.instance.client
          .from('weekly_challenges')
          .select()
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();
      setState(() {
        _challenge = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _challenge == null) return const SizedBox();

    final target = _challenge!['target'] as int;
    const progress = 3;
    final percent = (progress / target).clamp(0.0, 1.0);
    final daysLeft = DateTime.parse(_challenge!['end_date'])
        .difference(DateTime.now())
        .inDays;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WeeklyChallengeScreen()),
      ),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (_, __) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4FF)
                  .withOpacity(0.25 + 0.25 * _shimmerAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF)
                    .withOpacity(0.1 * _shimmerAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_challenge!['badge'], style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التحدي الأسبوعي',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _challenge!['title'],
                          style: const TextStyle(
                            color: Color(0xFFF0F4FF),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4757).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFF4757).withOpacity(0.3)),
                    ),
                    child: Text(
                      '$daysLeft يوم',
                      style: const TextStyle(
                        color: Color(0xFFFF4757),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: const Color(0xFF0F1E35),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF00D4FF)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$progress / $target جولة',
                    style: const TextStyle(color: Color(0xFF8BA0C8), fontSize: 11),
                  ),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF00D4FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}