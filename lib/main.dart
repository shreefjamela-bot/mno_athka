// ==============================
// الملف الرئيسي — منو أذكى
// Luxury Dark Theme
// ==============================

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
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return _dailyFacts[dayOfYear % _dailyFacts.length];
}

// ألوان الثيم الفاخر
const _gold = Color(0xFFC49830);
const _goldLight = Color(0xFFF0D060);
const _goldDark = Color(0xFF6B4A10);
const _bg = Color(0xFF080808);
const _cardBg = Color(0xFF0E0E0E);
const _goldText = Color(0xFF5A4820);

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
      final twinkleSpeed = i % 3 == 0 ? 2.0 : i % 3 == 1 ? 1.2 : 0.7;
      final opacity =
      (sin(progress * 2 * pi * twinkleSpeed + twinkleOffsets[i]) * 0.3 + 0.4)
          .clamp(0.05, 0.7);
      canvas.drawCircle(
        Offset(stars[i].dx * size.width, stars[i].dy * size.height),
        sizes[i],
        Paint()
          ..color = const Color(0xFFC49830).withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.progress != progress;
}

// ==============================
// فيديو تعريفي
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
            ..src = 'https://qfvobkacbxeyaybfcuju.supabase.co/storage/v1/object/public/questions-media/wajha.mp4'
            ..autoplay = false
            ..loop = true
            ..muted = true
            ..controls = true
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover'
            ..style.borderRadius = '12px'
            ..style.background = 'transparent';
          return video;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_outline_rounded, color: _gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'تعرف على اللعبة',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: _gold.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: const HtmlElementView(viewType: 'mno-video-player'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '🔊 اضغط على الفيديو لتشغيل الصوت',
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: _goldText.withOpacity(0.6),
              fontSize: 10,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==============================
// بطاقة Luxury
// ==============================
class _LuxuryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _LuxuryCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withOpacity(0.35), width: 0.8),
      ),
      child: child,
    );
  }
}

// ==============================
// زر أيقونة علوي
// ==============================
class _TopIconBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _TopIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _gold.withOpacity(0.5), width: 0.8),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

// ==============================
// زر ثانوي
// ==============================
class _SecondaryBtn extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SecondaryBtn> createState() => _SecondaryBtnState();
}

class _SecondaryBtnState extends State<_SecondaryBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 2.0 : 0.0),
        decoration: BoxDecoration(
          color: _pressed ? _gold.withOpacity(0.08) : _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _gold.withOpacity(_pressed ? 0.7 : 0.4),
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon,
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                color: _goldText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
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
  bool _playPressed = false;

  final _random = Random(42);
  late final List<Offset> _stars;
  late final List<double> _starSizes;
  late final List<double> _twinkleOffsets;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(50, (_) => Offset(_random.nextDouble(), _random.nextDouble()));
    _starSizes = List.generate(50, (_) => _random.nextDouble() * 1.5 + 0.3);
    _twinkleOffsets = List.generate(50, (_) => _random.nextDouble() * 2 * pi);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entranceFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [

          // نجوم خفيفة
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

          // توهج ذهبي خفيف في المنتصف
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _gold.withOpacity(0.04 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
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
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [

                        const SizedBox(height: 12),

                        // شريط علوي
                        Row(
                          children: [
                            _TopIconBtn(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                              icon: _LeaderboardIcon(),
                            ),
                            const Spacer(),
                            _TopIconBtn(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const ProfileScreen())),
                              icon: _ProfileIcon(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ===== اللوغو =====
                        _buildLogo(),

                        const SizedBox(height: 32),

                        // ===== زر ابدأ اللعب =====
                        GestureDetector(
                          onTapDown: (_) => setState(() => _playPressed = true),
                          onTapUp: (_) {
                            setState(() => _playPressed = false);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const DraftScreen()));
                          },
                          onTapCancel: () => setState(() => _playPressed = false),
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (_, __) => AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: double.infinity,
                              height: 58,
                              transform: Matrix4.identity()
                                ..translate(0.0, _playPressed ? 3.0 : 0.0),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3D2800),
                                    Color(0xFFB8890A),
                                    Color(0xFFE8C840),
                                    Color(0xFFF0D060),
                                    Color(0xFFE8C840),
                                    Color(0xFFB8890A),
                                    Color(0xFF3D2800),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(29),
                                boxShadow: _playPressed
                                    ? []
                                    : [
                                  BoxShadow(
                                    color: _gold.withOpacity(0.4 * _glowAnimation.value),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A0E00).withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Color(0xFF1A0E00),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'ابدأ اللعب',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1A0E00),
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== شبكة الأزرار =====
                        SizedBox(
                          height: 140,
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.8,
                            children: [
                              _SecondaryBtn(
                                icon: _TrophyIcon(),
                                label: 'التحدي الأسبوعي',
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const WeeklyChallengeScreen())),
                              ),
                              _SecondaryBtn(
                                icon: _FolderIcon(),
                                label: 'فئتك الخاصة',
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const CustomCategoriesScreen())),
                              ),
                              _SecondaryBtn(
                                icon: _PenIcon(),
                                label: 'أضف سؤالك',
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const UserQuestionsScreen())),
                              ),
                              _SecondaryBtn(
                                icon: _ChatIcon(),
                                label: 'اقتراحاتك تهمنا',
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const SuggestionsScreen())),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ===== فيديو =====
                        const _VideoCard(),

                        const SizedBox(height: 16),

                        // ===== التحدي الأسبوعي =====
                        const _WeeklyChallengeCard(),

                        const SizedBox(height: 16),

                        // ===== كل يوم معلومة =====
                        _LuxuryCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _BulbIcon(),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'كل يوم معلومة',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: _gold.withOpacity(0.7),
                                        fontSize: 11,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _getDailyFact(),
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: _goldText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.6,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== تذييل =====
                        _LuxuryCard(
                          child: Text(
                            'استمتعوا بأوقاتكم مع لعبة منو أذكى\nلعبة المعلومات والتحدي اللي تجمع الأهل والأصدقاء',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: _goldText.withOpacity(0.6),
                              height: 1.8,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 32),
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

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) => Column(
        children: [
          // خط زخرفي علوي
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, _gold.withOpacity(0.4)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _StarIcon(),
              ),
              Expanded(
                child: Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_gold.withOpacity(0.4), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // منو
          Text(
            'منو',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 26,
              fontWeight: FontWeight.w300,
              color: _gold.withOpacity(0.85),
              letterSpacing: 14,
              shadows: [
                Shadow(
                  color: _gold.withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 20,
                ),
              ],
            ),
          ),

          // أذكى
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_goldLight, _gold, _goldDark],
            ).createShader(bounds),
            child: Text(
              'أذكى؟',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: _gold.withOpacity(0.5 * _glowAnimation.value),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // خط فاصل
          Container(
            width: 200,
            height: 0.4,
            color: _gold.withOpacity(0.2),
          ),

          const SizedBox(height: 8),

          // وصف
          Text(
            'مسابقات وتحديات ذكية',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              color: _goldText.withOpacity(0.8),
              letterSpacing: 5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================
// أيقونات SVG مخصصة
// ==============================

class _LeaderboardIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _LeaderboardPainter()),
    );
  }
}

class _LeaderboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _gold
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.55, size.width * 0.28, size.height * 0.45), p..color = _gold.withOpacity(0.5));
    canvas.drawRect(Rect.fromLTWH(size.width * 0.36, size.height * 0.3, size.width * 0.28, size.height * 0.7), p..color = _gold.withOpacity(0.75));
    canvas.drawRect(Rect.fromLTWH(size.width * 0.72, size.height * 0.05, size.width * 0.28, size.height * 0.95), p..color = _gold);

    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), stroke..color = _gold.withOpacity(0.6));

    final starPath = Path();
    final sc = Offset(size.width * 0.86, size.height * 0.0);
    final r = size.width * 0.09;
    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * (pi / 180);
      final radius = i.isEven ? r : r * 0.45;
      final x = sc.dx + radius * cos(angle);
      final y = sc.dy + radius * sin(angle);
      if (i == 0) starPath.moveTo(x, y); else starPath.lineTo(x, y);
    }
    starPath.close();
    canvas.drawPath(starPath, p..color = _goldLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProfileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _ProfilePainter()),
    );
  }
}

class _ProfilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(size.width / 2, size.height * 0.35), size.width * 0.22, stroke);

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(0, size.height * 0.65, size.width / 2, size.height * 0.65)
      ..quadraticBezierTo(size.width, size.height * 0.65, size.width, size.height);
    canvas.drawPath(path, stroke);

    final crownPath = Path()
      ..moveTo(size.width * 0.28, size.height * 0.12)
      ..lineTo(size.width * 0.36, size.height * 0.04)
      ..lineTo(size.width * 0.5, size.height * 0.12)
      ..lineTo(size.width * 0.64, size.height * 0.04)
      ..lineTo(size.width * 0.72, size.height * 0.12);
    canvas.drawPath(crownPath, stroke..color = _gold.withOpacity(0.6)..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrophyIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _TrophyPainter()),
    );
  }
}

class _TrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.2, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.75, size.width * 0.5, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.75, size.width * 0.8, size.height * 0.55)
      ..lineTo(size.width * 0.8, 0)
      ..close();
    canvas.drawPath(body, stroke);

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.2, size.height * 0.2)
        ..quadraticBezierTo(0, size.height * 0.2, 0, size.height * 0.45)
        ..quadraticBezierTo(0, size.height * 0.65, size.width * 0.2, size.height * 0.65),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.8, size.height * 0.2)
        ..quadraticBezierTo(size.width, size.height * 0.2, size.width, size.height * 0.45)
        ..quadraticBezierTo(size.width, size.height * 0.65, size.width * 0.8, size.height * 0.65),
      stroke,
    );

    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.75), Offset(size.width * 0.5, size.height * 0.88), stroke);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.88), Offset(size.width * 0.7, size.height * 0.88), stroke..strokeWidth = 1.5);

    final starPath = Path();
    final sc = Offset(size.width * 0.5, size.height * 0.38);
    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * (pi / 180);
      final r = i.isEven ? size.width * 0.14 : size.width * 0.06;
      final x = sc.dx + r * cos(angle);
      final y = sc.dy + r * sin(angle);
      if (i == 0) starPath.moveTo(x, y); else starPath.lineTo(x, y);
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = _goldLight..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FolderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _FolderPainter()),
    );
  }
}

class _FolderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final folder = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(0, size.height * 0.9)
      ..quadraticBezierTo(0, size.height, size.width * 0.08, size.height)
      ..lineTo(size.width * 0.92, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height * 0.9)
      ..lineTo(size.width, size.height * 0.38)
      ..quadraticBezierTo(size.width, size.height * 0.28, size.width * 0.92, size.height * 0.28)
      ..lineTo(size.width * 0.48, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.28, size.width * 0.36, size.height * 0.2)
      ..lineTo(size.width * 0.2, size.height * 0.2)
      ..quadraticBezierTo(0, size.height * 0.2, 0, size.height * 0.3)
      ..close();
    canvas.drawPath(folder, stroke);

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.58),
      Offset(size.width * 0.8, size.height * 0.58),
      stroke..color = _gold.withOpacity(0.5)..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.72),
      Offset(size.width * 0.65, size.height * 0.72),
      stroke..color = _gold.withOpacity(0.5)..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PenIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _PenPainter()),
    );
  }
}

class _PenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pen = Path()
      ..moveTo(size.width * 0.15, size.height * 0.75)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.2, size.width * 0.82, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.05, size.width * 0.92, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.35, size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.25, size.height * 0.85)
      ..close();
    canvas.drawPath(pen, stroke);

    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.75),
      Offset(size.width * 0.08, size.height * 0.95),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.95),
      Offset(size.width * 0.28, size.height * 0.88),
      stroke,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.38),
      Offset(size.width * 0.62, size.height * 0.5),
      stroke..color = _gold.withOpacity(0.5)..strokeWidth = 1,
    );

    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.1),
      stroke..color = _gold..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(size.width * 0.84, size.height * 0.04),
      Offset(size.width * 0.84, size.height * 0.16),
      stroke..color = _gold..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChatIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _ChatPainter()),
    );
  }
}

class _ChatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bubble = Path()
      ..moveTo(size.width * 0.12, 0)
      ..lineTo(size.width * 0.88, 0)
      ..quadraticBezierTo(size.width, 0, size.width, size.height * 0.12)
      ..lineTo(size.width, size.height * 0.62)
      ..quadraticBezierTo(size.width, size.height * 0.74, size.width * 0.88, size.height * 0.74)
      ..lineTo(size.width * 0.45, size.height * 0.74)
      ..lineTo(size.width * 0.28, size.height * 0.95)
      ..lineTo(size.width * 0.28, size.height * 0.74)
      ..lineTo(size.width * 0.12, size.height * 0.74)
      ..quadraticBezierTo(0, size.height * 0.74, 0, size.height * 0.62)
      ..lineTo(0, size.height * 0.12)
      ..quadraticBezierTo(0, 0, size.width * 0.12, 0)
      ..close();
    canvas.drawPath(bubble, stroke);

    final heartPath = Path();
    final hc = Offset(size.width * 0.5, size.height * 0.35);
    heartPath.moveTo(hc.dx, hc.dy + size.height * 0.12);
    heartPath.cubicTo(
      hc.dx, hc.dy, hc.dx - size.width * 0.18, hc.dy, hc.dx - size.width * 0.18, hc.dy - size.height * 0.06,
    );
    heartPath.cubicTo(
      hc.dx - size.width * 0.18, hc.dy - size.height * 0.15, hc.dx, hc.dy - size.height * 0.12, hc.dx, hc.dy,
    );
    heartPath.cubicTo(
      hc.dx, hc.dy - size.height * 0.12, hc.dx + size.width * 0.18, hc.dy - size.height * 0.15, hc.dx + size.width * 0.18, hc.dy - size.height * 0.06,
    );
    heartPath.cubicTo(
      hc.dx + size.width * 0.18, hc.dy, hc.dx, hc.dy, hc.dx, hc.dy + size.height * 0.12,
    );
    canvas.drawPath(heartPath, Paint()..color = _gold..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BulbIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _BulbPainter()),
    );
  }
}

class _BulbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(size.width / 2, size.height * 0.4), size.width * 0.28, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.35, size.height * 0.65)
        ..quadraticBezierTo(size.width * 0.35, size.height * 0.75, size.width * 0.5, size.height * 0.75)
        ..quadraticBezierTo(size.width * 0.65, size.height * 0.75, size.width * 0.65, size.height * 0.65),
      stroke,
    );
    canvas.drawLine(Offset(size.width * 0.38, size.height * 0.78), Offset(size.width * 0.62, size.height * 0.78), stroke);
    canvas.drawLine(Offset(size.width * 0.42, size.height * 0.82), Offset(size.width * 0.58, size.height * 0.82), stroke);

    for (final angle in [270.0, 225.0, 315.0, 180.0, 0.0]) {
      final rad = angle * pi / 180;
      final inner = Offset(size.width / 2 + cos(rad) * size.width * 0.32, size.height * 0.4 + sin(rad) * size.width * 0.32);
      final outer = Offset(size.width / 2 + cos(rad) * size.width * 0.44, size.height * 0.4 + sin(rad) * size.width * 0.44);
      canvas.drawLine(inner, outer, stroke..color = _gold.withOpacity(0.5)..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(painter: _StarPainter()),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * (pi / 180);
      final r = i.isEven ? size.width / 2 : size.width / 4;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _gold.withOpacity(0.7)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      duration: const Duration(milliseconds: 2000),
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
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const WeeklyChallengeScreen())),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (_, __) => _LuxuryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TrophyIcon(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التحدي الأسبوعي',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: _gold.withOpacity(0.6),
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          _challenge!['title'],
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            color: _goldText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$daysLeft يوم',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: _gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: _gold.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(_gold.withOpacity(0.7)),
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$progress / $target جولة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: _goldText.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: _gold.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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