// ==============================
// الملف الرئيسي للتطبيق
// اسم اللعبة: منو أذكى
// ==============================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/supabase_config.dart';
import 'features/game/draft_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/leaderboard_screen.dart';

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
// معلومة اليوم — تتغير كل 24 ساعة
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
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return _dailyFacts[dayOfYear % _dailyFacts.length];
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
  late PageController _imageController;
  Timer? _imageTimer;
  int _currentImage = 0;

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

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

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
    _imageController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.leaderboard, color: AppColors.primary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                const SizedBox(height: 16),

                // ── اسم اللعبة ──────────────────────────
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (_, __) => ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'منو أذكى ؟',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: AppColors.primary
                                .withOpacity(0.5 * _glowAnimation.value),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'واجهني ونشوف منو الأذكى',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    letterSpacing: 2,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // ── زر ابدأ اللعب ───────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DraftScreen()),
                  ),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (_, __) => Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryDark,
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withOpacity(0.4 * _glowAnimation.value),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🎮  ابدأ اللعب',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.background,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── زر لوحة المتصدرين ───────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LeaderboardScreen()),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorderGold),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.leaderboard,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'لوحة المتصدرين',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── كل يوم معلومة ───────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.cardBorderGold, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.glowGold, blurRadius: 12),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.primary, width: 1),
                            ),
                            child: const Row(
                              children: [
                                Text('💡',
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(width: 6),
                                Text(
                                  'كل يوم معلومة',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

                // ── الصور المربعة ────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 4, bottom: 10),
                      child: Text(
                        'لحظات اللعبة',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // الصور في PageView
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _imageController,
                        itemCount: _images.length,
                        onPageChanged: (i) =>
                            setState(() => _currentImage = i),
                        itemBuilder: (ctx, i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              _images[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceColor,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: AppColors.textHint, size: 40),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // نقاط التنقل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _images.length,
                            (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentImage == i ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentImage == i
                                ? AppColors.primary
                                : AppColors.textHint.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── جملة الترحيب ─────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.cardBorderGold, width: 1),
                  ),
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
    );
  }
}