// ==============================
// شاشة التحدي الأسبوعي
// اسم الملف: weekly_challenge_screen.dart
// ==============================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';

class WeeklyChallengeScreen extends StatefulWidget {
  const WeeklyChallengeScreen({super.key});

  @override
  State<WeeklyChallengeScreen> createState() =>
      _WeeklyChallengeScreenState();
}

class _WeeklyChallengeScreenState extends State<WeeklyChallengeScreen>
    with TickerProviderStateMixin {

  Map<String, dynamic>? _challenge;
  int _progress = 0;
  bool _isLoading = true;
  bool _completed = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadChallenge();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
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
        if (_challenge != null) {
          _progress = 3; // تجريبي — سيُربط بالمستخدم لاحقاً
          _completed = _progress >= (_challenge!['target'] as int);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'التحدي الملحمي الأسبوعي',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
            child: CircularProgressIndicator(
                color: AppColors.primary))
            : _challenge == null
            ? _buildNoChallenge()
            : _buildChallenge(),
      ),
    );
  }

  Widget _buildNoChallenge() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🏆', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text(
            'لا يوجد تحدي هذا الأسبوع',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'تابعنا للتحديات القادمة!',
            style: TextStyle(
                color: AppColors.textHint, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChallenge() {
    final target = _challenge!['target'] as int;
    final progress = _progress.clamp(0, target);
    final percent = progress / target;
    final daysLeft = DateTime.parse(_challenge!['end_date'])
        .difference(DateTime.now())
        .inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [

          // بطاقة التحدي الرئيسية
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Transform.scale(
              scale: _completed ? 1.0 : _pulseAnimation.value,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _completed
                        ? AppColors.correct
                        : AppColors.cardBorderGold,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _completed
                          ? AppColors.correct.withOpacity(0.3)
                          : AppColors.glowGold,
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // الشارة
                    Text(
                      _challenge!['badge'],
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),

                    // العنوان
                    Text(
                      _challenge!['title'],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // الوصف
                    Text(
                      _challenge!['description'],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // شريط التقدم
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'التقدم: $progress / $target',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$daysLeft يوم متبقي',
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor:
                            AppColors.surfaceColor,
                            valueColor: AlwaysStoppedAnimation(
                              _completed
                                  ? AppColors.correct
                                  : AppColors.primary,
                            ),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '${(percent * 100).toInt()}%',
                            style: TextStyle(
                              color: _completed
                                  ? AppColors.correct
                                  : AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // بطاقة المكافأة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.gold.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المكافأة عند الإتمام',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _challenge!['reward'],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // حالة الإتمام
          if (_completed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.correct.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.correct, width: 2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events,
                      color: AppColors.correct, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'أتممت التحدي! مبروك 🎉',
                    style: TextStyle(
                      color: AppColors.correct,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Text(
                '💡 العب جولات في اللعبة لتزيد تقدمك في التحدي',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}