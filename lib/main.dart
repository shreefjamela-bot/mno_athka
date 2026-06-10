// ==============================
// الملف الرئيسي للتطبيق
// اسم اللعبة: منو أذكى
// ==============================

import 'dart:async';
import 'dart:math';
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

// ==============================
// معلومة اليوم
// ==============================
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
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year))
      .inDays;
  return _dailyFacts[dayOfYear % _dailyFacts.length];
}

// ==============================
// رسام النجوم المتلألئة
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
      // بعض النجوم تتلألأ بسرعة والبعض ببطء
      final twinkleSpeed = i % 3 == 0 ? 3.0 : i % 3 == 1 ? 1.5 : 0.8;
      final opacity = (sin(progress * 2 * pi * twinkleSpeed + twinkleOffsets[i]) * 0.35 + 0.5)
          .clamp(0.1, 0.9);

      // نجوم أكبر تحصل على هالة
      if (sizes[i] > 1.2) {
        final haloPaint = Paint()
          ..color = AppColors.primary.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(
          Offset(stars[i].dx * size.width, stars[i].dy * size.height),
          sizes[i] * 2.5,
          haloPaint,
        );
      }

      final paint = Paint()
        ..color = i % 4 == 0
            ? AppColors.secondary.withOpacity(opacity)
            : AppColors.primary.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(stars[i].dx * size.width, stars[i].dy * size.height),
        sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.progress != progress;
}

// ==============================
// الشاشة الرئيسية
// ==============================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _starsController;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;
  late PageController _imageController;
  Timer? _imageTimer;
  int _currentImage = 0;
  int? _pressedButton;

  final _random = Random(42);
  late final List<Offset> _stars;
  late final List<double> _starSizes;
  late final List<double> _twinkleOffsets;

  final List<String> _images = [
    'assets/images/wrg.png',
    'assets/images/sin.png',
    'assets/images/kasalm.png',
    'assets/images/kalb.png',
    'assets/images/jwad.png',
    'assets/images/ibn.png',
    'assets/images/hamza.png',
    'assets/images/banat.png',
  ];

  @override
  void initState() {
    super.initState();

    _stars = List.generate(
      50,
          (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    );
    _starSizes = List.generate(
        50, (_) => _random.nextDouble() * 2.0 + 0.5);
    _twinkleOffsets = List.generate(
        50, (_) => _random.nextDouble() * 2 * pi);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
          parent: _glowController, curve: Curves.easeInOut),
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
      CurvedAnimation(
          parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entranceController, curve: Curves.easeOut));
    _entranceController.forward();

    _imageController = PageController();
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _currentImage = (_currentImage + 1) % _images.length;
        });
        _imageController.animateToPage(
          _currentImage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _starsController.dispose();
    _entranceController.dispose();
    _imageController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  // ── زر موحد النمط ────────────────────────────────
  Widget _buildButton({
    required String emoji,
    required String label,
    required VoidCallback onTap,
    required int index,
    bool isPrimary = false,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.secondary;
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
          height: isPrimary ? 64 : 54,
          transform: Matrix4.identity()
            ..translate(0.0, isPressed ? 3.0 : 0.0),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
              colors: [
                const Color(0xFFB8963E),
                const Color(0xFFE8C97A),
                const Color(0xFFF5DFA0),
                const Color(0xFFE8C97A),
                const Color(0xFFB8963E),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
                : LinearGradient(
              colors: [
                color.withOpacity(0.18),
                color.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
              color: color.withOpacity(
                  0.5 + 0.3 * _glowAnimation.value),
              width: 1.5,
            ),
            boxShadow: isPressed
                ? []
                : isPrimary
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(
                    0.6 * _glowAnimation.value),
                blurRadius: 25,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.primaryLight
                    .withOpacity(0.3),
                blurRadius: 50,
                spreadRadius: 6,
              ),
            ]
                : [
              BoxShadow(
                color: color.withOpacity(
                    0.3 * _glowAnimation.value),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji,
                  style: TextStyle(
                      fontSize: isPrimary ? 24 : 20)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: isPrimary ? 20 : 15,
                  fontWeight: FontWeight.bold,
                  color: isPrimary
                      ? AppColors.background
                      : color,
                  letterSpacing: isPrimary ? 2 : 0.5,
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
          gradient: LinearGradient(
            colors: [
              AppColors.cardBackground,
              AppColors.surfaceColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.cardBorderGold,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary
                  .withOpacity(0.1 * _glowAnimation.value),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 4),
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          // ── تدرج الخلفية الرئيسي ─────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A2A5E),
                    AppColors.background,
                    const Color(0xFF060A18),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── نجوم متلألئة ─────────────────────────
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

          // ── هالة ذهبية خلف العنوان ───────────────
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Center(
                child: Container(
                  width: 250,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(
                            0.15 * _glowAnimation.value),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── المحتوى ──────────────────────────────
          SafeArea(
            child: Column(
              children: [

                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.leaderboard,
                            color: AppColors.primary),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const LeaderboardScreen()),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.person_outline,
                            color: AppColors.textPrimary),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const ProfileScreen()),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: FadeTransition(
                    opacity: _entranceFade,
                    child: SlideTransition(
                      position: _entranceSlide,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: Column(
                          children: [

                            const SizedBox(height: 8),

                            // ── اسم اللعبة ──────────
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (_, __) => Column(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            AppColors.primaryLight,
                                            Color(0xFFF5DFA0),
                                            AppColors.primary,
                                            AppColors.primaryDark,
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      'منو أذكى ؟',
                                      style: TextStyle(
                                        fontSize: 58,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 5,
                                        shadows: [
                                          Shadow(
                                            color: AppColors.primary
                                                .withOpacity(0.7 *
                                                _glowAnimation
                                                    .value),
                                            blurRadius: 35,
                                          ),
                                          Shadow(
                                            color: AppColors.secondary
                                                .withOpacity(0.3 *
                                                _glowAnimation
                                                    .value),
                                            blurRadius: 60,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'واجهني ونشوف منو الأذكى',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary
                                          .withOpacity(0.8),
                                      letterSpacing: 2,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── الأزرار ─────────────
                            _buildButton(
                              emoji: '🎮',
                              label: 'ابدأ اللعب',
                              isPrimary: true,
                              index: 0,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const DraftScreen()),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildButton(
                              emoji: '🦅',
                              label: 'التحدي الأسبوعي',
                              index: 1,
                              accentColor: AppColors.secondary,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const WeeklyChallengeScreen()),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildButton(
                              emoji: '✍️',
                              label: 'أضف سؤالك',
                              index: 2,
                              accentColor: AppColors.correct,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const UserQuestionsScreen()),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildButton(
                              emoji: '🗂️',
                              label: 'فئتك الخاصة',
                              index: 3,
                              accentColor: AppColors.gold,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const CustomCategoriesScreen()),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildButton(
                              emoji: '💬',
                              label: 'اقتراحاتك تهمنا',
                              index: 4,
                              accentColor: AppColors.purple,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const SuggestionsScreen()),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── بطاقة التحدي ─────────
                            const _WeeklyChallengeCard(),

                            const SizedBox(height: 20),

                            // ── كل يوم معلومة ────────
                            _buildDepthCard(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withOpacity(0.15),
                                      borderRadius:
                                      BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.primary,
                                          width: 1),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('💡',
                                            style: TextStyle(
                                                fontSize: 14)),
                                        SizedBox(width: 6),
                                        Text(
                                          'كل يوم معلومة',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _getDailyFact(),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
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

                            // ── لحظات اللعبة ─────────
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 4, bottom: 10),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        LinearGradient(colors: [
                                          AppColors.primary,
                                          AppColors.secondary,
                                        ]).createShader(bounds),
                                    child: const Text(
                                      'لحظات اللعبة ✨',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 200,
                                  child: PageView.builder(
                                    controller: _imageController,
                                    itemCount: _images.length,
                                    onPageChanged: (i) => setState(
                                            () => _currentImage = i),
                                    itemBuilder: (ctx, i) => Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
                                              blurRadius: 15,
                                              offset:
                                              const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(
                                              16),
                                          child: Image.asset(
                                            _images[i],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) =>
                                                Container(
                                                  color: AppColors
                                                      .surfaceColor,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported,
                                                      color: AppColors
                                                          .textHint,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: List.generate(
                                    _images.length,
                                        (i) => AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 300),
                                      margin: const EdgeInsets
                                          .symmetric(horizontal: 3),
                                      width:
                                      _currentImage == i ? 20 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _currentImage == i
                                            ? AppColors.primary
                                            : AppColors.textHint
                                            .withOpacity(0.4),
                                        borderRadius:
                                        BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── جملة الترحيب ──────────
                            _buildDepthCard(
                              child: const Text(
                                'استمتعوا بأوقاتكم مع لعبة " منو أذكى "\nلعبة المعلومات والتحدي اللي تجمع الأهل والأصدقاء',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
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

// ==============================
// بطاقة التحدي الأسبوعي
// ==============================
class _WeeklyChallengeCard extends StatefulWidget {
  const _WeeklyChallengeCard();

  @override
  State<_WeeklyChallengeCard> createState() =>
      _WeeklyChallengeCardState();
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
      CurvedAnimation(
          parent: _shimmerController, curve: Curves.easeInOut),
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
        MaterialPageRoute(
            builder: (_) => const WeeklyChallengeScreen()),
      ),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (_, __) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.cardBackground,
                AppColors.secondary
                    .withOpacity(0.05 * _shimmerAnimation.value),
                AppColors.cardBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.secondary.withOpacity(
                  0.3 + 0.3 * _shimmerAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary
                    .withOpacity(0.15 * _shimmerAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_challenge!['badge'],
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التحدي الأسبوعي',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _challenge!['title'],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.wrong.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.wrong.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$daysLeft يوم',
                      style: const TextStyle(
                        color: AppColors.wrong,
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
                  backgroundColor: AppColors.surfaceColor,
                  valueColor:
                  AlwaysStoppedAnimation(AppColors.secondary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$progress / $target جولة',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      color: AppColors.secondary,
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