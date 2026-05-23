// ==============================
// شاشة لوحة المتصدرين
// اسم الملف: leaderboard_screen.dart
// المكان: lib/features/
//
// تعرض أفضل اللاعبين ونقاطهم
// ==============================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {

  // قائمة المتصدرين
  List<Map<String, dynamic>> _leaders = [];

  // هل يحمّل
  bool _isLoading = true;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  // ==============================
  // جيب المتصدرين من Supabase
  // ==============================
  Future<void> _loadLeaderboard() async {
    try {
      final response = await _supabase
          .from('leaderboard')
          .select()
          .order('total_points', ascending: false)
          .limit(20); // أعلى ٢٠ لاعب

      setState(() {
        _leaders = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ==============================
  // أيقونة المركز
  // ==============================
  String _getRankEmoji(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '${rank}';
  }

  // ==============================
  // لون المركز
  // ==============================
  Color _getRankColor(int rank) {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          '🏆 لوحة المتصدرين',
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
          : _leaders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎮', style: TextStyle(fontSize: 60)),
            SizedBox(height: AppSizes.spaceMD),
            Text(
              'ما في متصدرين بعد!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.spaceSM),
            Text(
              'كن أول من يسجل نقاطه',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontLG,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        itemCount: _leaders.length,
        itemBuilder: (context, index) {
          final leader = _leaders[index];
          final rank = index + 1;

          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.spaceMD),
            padding: const EdgeInsets.all(AppSizes.spaceMD),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius:
              BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(
                color: rank <= 3
                    ? _getRankColor(rank)
                    : AppColors.surfaceColor,
                width: rank <= 3 ? 2 : 1,
              ),
            ),
            child: Row(
              children: [

                // ==============================
                // المركز
                // ==============================
                SizedBox(
                  width: 40,
                  child: Text(
                    _getRankEmoji(rank),
                    style: TextStyle(
                      fontSize: rank <= 3 ? 28 : 18,
                      color: _getRankColor(rank),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(width: AppSizes.spaceMD),

                // ==============================
                // صورة اللاعب
                // ==============================
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(
                      color: _getRankColor(rank),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),

                const SizedBox(width: AppSizes.spaceMD),

                // ==============================
                // اسم اللاعب وإحصائياته
                // ==============================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leader['username'] ?? 'لاعب',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppSizes.fontLG,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${leader['total_games'] ?? 0} جولة',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontSM,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==============================
                // النقاط
                // ==============================
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${leader['total_points'] ?? 0}',
                      style: TextStyle(
                        color: _getRankColor(rank),
                        fontSize: AppSizes.fontXXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'نقطة',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSM,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}