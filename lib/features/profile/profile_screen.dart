// ==============================
// شاشة الملف الشخصي
// اسم الملف: profile_screen.dart
// المكان: lib/features/profile/
// ==============================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/repositories/local_storage.dart' as AppStorage;
import '../auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  int _highScore = 0;
  int _totalGames = 0;
  int _correctAnswers = 0;
  bool _isLoading = true;

  // اتصال Supabase
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final highScore = await AppStorage.LocalStorage.getHighScore();
    final totalGames = await AppStorage.LocalStorage.getTotalGames();
    final correctAnswers = await AppStorage.LocalStorage.getCorrectAnswers();

    setState(() {
      _highScore = highScore;
      _totalGames = totalGames;
      _correctAnswers = correctAnswers;
      _isLoading = false;
    });
  }

  // ==============================
  // دالة تسجيل الخروج
  // ==============================
  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الخروج'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // هل المستخدم مسجّل دخول
    final user = _supabase.auth.currentUser;
    final isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'ملفي الشخصي',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        child: Column(
          children: [

            const SizedBox(height: AppSizes.spaceLG),

            // صورة اللاعب
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(
                  color: AppColors.gold,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // اسم اللاعب أو إيميله
            Text(
              isLoggedIn
                  ? user.email ?? 'لاعب'
                  : 'لاعب جديد',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontLG,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // إحصائيات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  emoji: '🏆',
                  label: 'أعلى نقاط',
                  value: '$_highScore',
                  color: AppColors.gold,
                ),
                _StatCard(
                  emoji: '🎮',
                  label: 'عدد الجولات',
                  value: '$_totalGames',
                  color: AppColors.primary,
                ),
                _StatCard(
                  emoji: '✅',
                  label: 'إجابات صح',
                  value: '$_correctAnswers',
                  color: AppColors.correct,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // ==============================
            // زر تسجيل الدخول أو الخروج
            // ==============================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (isLoggedIn) {
                    await _signOut();
                  } else {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(),
                      ),
                    );
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLoggedIn
                      ? AppColors.wrong
                      : AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spaceMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                child: Text(
                  isLoggedIn ? '🚪 تسجيل الخروج' : '🔑 تسجيل الدخول',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
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
      ),
    );
  }
}