// ==============================
// شاشة لوحة المباراة — نظام سين جيم
// اسم الملف: match_board_screen.dart
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';
import 'game_screen.dart';
import 'result_screen.dart';

class MatchBoardScreen extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  final List<CategoryModel> team1Categories;
  final List<CategoryModel> team2Categories;

  const MatchBoardScreen({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.team1Categories,
    required this.team2Categories,
  });

  @override
  State<MatchBoardScreen> createState() => _MatchBoardScreenState();
}

class _MatchBoardScreenState extends State<MatchBoardScreen>
    with TickerProviderStateMixin {

  int _team1Points = 0;
  int _team2Points = 0;
  int _currentTeam = 1;

  // كل فئة + مستوى = مفتاح فريد
  // مثال: 'cat_id_1' → {1: true, 2: false, 3: false}
  Map<String, Map<int, bool>> _playedMap = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // تهيئة الخريطة
    for (final cat in [
      ...widget.team1Categories,
      ...widget.team2Categories
    ]) {
      _playedMap[cat.id] = {1: false, 2: false, 3: false};
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int _levelPoints(int level) => level == 1 ? 200 : level == 2 ? 400 : 600;

  Color _levelColor(int level) {
    if (level == 1) return AppColors.level1;
    if (level == 2) return AppColors.level2;
    return AppColors.level3;
  }

  bool _isPlayed(String catId, int level) =>
      _playedMap[catId]?[level] ?? false;

  // هل الفئة للفريق الحالي
  bool _isCurrentTeamCategory(CategoryModel cat) {
    if (_currentTeam == 1) {
      return widget.team1Categories.any((c) => c.id == cat.id);
    }
    return widget.team2Categories.any((c) => c.id == cat.id);
  }

  // هل كل الخانات انلعبت
  bool get _isGameOver {
    for (final cat in [
      ...widget.team1Categories,
      ...widget.team2Categories
    ]) {
      for (int level = 1; level <= 3; level++) {
        if (!_isPlayed(cat.id, level)) return false;
      }
    }
    return true;
  }

  void _playCell(CategoryModel category, int level) async {
    if (_isPlayed(category.id, level)) return;

    final result = await Navigator.push<Map<String, int>>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(
          level: level,
          category: category,
          team1Name: widget.team1Name,
          team2Name: widget.team2Name,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _playedMap[category.id]![level] = true;
        _team1Points += result['team1'] ?? 0;
        _team2Points += result['team2'] ?? 0;
        _currentTeam = _currentTeam == 1 ? 2 : 1;
      });

      if (_isGameOver) {
        Future.delayed(
          const Duration(milliseconds: 400),
          _showFinalResult,
        );
      }
    }
  }

  void _showFinalResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          totalPoints: _team1Points + _team2Points,
          correctAnswers: 0,
          totalQuestions: 18,
          category: widget.team1Categories.first,
          level: 3,
          team1Name: widget.team1Name,
          team2Name: widget.team2Name,
          team1Points: _team1Points,
          team2Points: _team2Points,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // عدد الخانات المتبقية
    int remaining = 0;
    for (final cat in [
      ...widget.team1Categories,
      ...widget.team2Categories
    ]) {
      for (int level = 1; level <= 3; level++) {
        if (!_isPlayed(cat.id, level)) remaining++;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // ==============================
            // الهيدر — النقاط
            // ==============================
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorderGold),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.glowGold, blurRadius: 10)
                ],
              ),
              child: Row(
                children: [

                  // الفريق ١
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔵',
                                style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.team1Name,
                                style: TextStyle(
                                  color: _currentTeam == 1
                                      ? AppColors.correct
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(colors: [
                                AppColors.primaryLight,
                                AppColors.correct,
                              ]).createShader(bounds),
                          child: Text(
                            '$_team1Points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_currentTeam == 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.correct.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('دورك ✨',
                                style: TextStyle(
                                    color: AppColors.correct,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),

                  // المنتصف
                  Column(
                    children: [
                      const Text('VS',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        'باقي $remaining',
                        style: const TextStyle(
                            color: AppColors.textHint, fontSize: 10),
                      ),
                    ],
                  ),

                  // الفريق ٢
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔴',
                                style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.team2Name,
                                style: TextStyle(
                                  color: _currentTeam == 2
                                      ? AppColors.wrong
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(colors: [
                                AppColors.primaryLight,
                                AppColors.wrong,
                              ]).createShader(bounds),
                          child: Text(
                            '$_team2Points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_currentTeam == 2)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.wrong.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('دورك ✨',
                                style: TextStyle(
                                    color: AppColors.wrong,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),

                ],
              ),
            ),

            // ==============================
            // اللوحة الرئيسية — عمودين
            // ==============================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  children: [

                    // عمود الفريق ١
                    Expanded(
                      child: Column(
                        children: [
                          // اسم الفريق
                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: _currentTeam == 1
                                  ? AppColors.correct.withOpacity(0.15)
                                  : AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _currentTeam == 1
                                    ? AppColors.correct
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              '🔵 ${widget.team1Name}',
                              style: TextStyle(
                                color: _currentTeam == 1
                                    ? AppColors.correct
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // فئات الفريق ١
                          Expanded(
                            child: ListView.separated(
                              itemCount: widget.team1Categories.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final cat =
                                widget.team1Categories[index];
                                final canPlay = _currentTeam == 1;
                                return _CategoryRow(
                                  category: cat,
                                  canPlay: canPlay,
                                  playedMap: _playedMap[cat.id]!,
                                  teamColor: AppColors.correct,
                                  pulseAnimation: canPlay
                                      ? _pulseAnimation
                                      : null,
                                  onLevelTap: (level) =>
                                      _playCell(cat, level),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // فاصل ذهبي
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.cardBorderGold,
                            AppColors.primary,
                            AppColors.cardBorderGold,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // عمود الفريق ٢
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: _currentTeam == 2
                                  ? AppColors.wrong.withOpacity(0.15)
                                  : AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _currentTeam == 2
                                    ? AppColors.wrong
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              '🔴 ${widget.team2Name}',
                              style: TextStyle(
                                color: _currentTeam == 2
                                    ? AppColors.wrong
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: ListView.separated(
                              itemCount: widget.team2Categories.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final cat =
                                widget.team2Categories[index];
                                final canPlay = _currentTeam == 2;
                                return _CategoryRow(
                                  category: cat,
                                  canPlay: canPlay,
                                  playedMap: _playedMap[cat.id]!,
                                  teamColor: AppColors.wrong,
                                  pulseAnimation: canPlay
                                      ? _pulseAnimation
                                      : null,
                                  onLevelTap: (level) =>
                                      _playCell(cat, level),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ==============================
// صف الفئة مع أزرار ٢٠٠/٤٠٠/٦٠٠
// ==============================
class _CategoryRow extends StatelessWidget {
  final CategoryModel category;
  final bool canPlay;
  final Map<int, bool> playedMap;
  final Color teamColor;
  final Animation<double>? pulseAnimation;
  final Function(int level) onLevelTap;

  const _CategoryRow({
    required this.category,
    required this.canPlay,
    required this.playedMap,
    required this.teamColor,
    required this.onLevelTap,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    // هل كل المستويات انلعبت
    final allPlayed =
        playedMap[1]! && playedMap[2]! && playedMap[3]!;

    Widget content = Container(
      decoration: BoxDecoration(
        color: allPlayed
            ? AppColors.surfaceColor.withOpacity(0.4)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allPlayed
              ? AppColors.textHint.withOpacity(0.2)
              : canPlay
              ? teamColor.withOpacity(0.5)
              : AppColors.cardBorder,
          width: canPlay && !allPlayed ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [

          // صورة الفئة
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: SizedBox(
              width: 52,
              height: 70,
              child: category.imageUrl != null
                  ? Image.network(
                category.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(category.emoji,
                      style: TextStyle(
                          fontSize: allPlayed ? 18 : 22)),
                ),
              )
                  : Container(
                color: AppColors.surfaceColor,
                child: Center(
                  child: Text(category.emoji,
                      style: TextStyle(
                          fontSize: allPlayed ? 18 : 22)),
                ),
              ),
            ),
          ),

          // أزرار المستويات
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 6),
              child: Column(
                children: [
                  // اسم الفئة
                  Text(
                    category.title,
                    style: TextStyle(
                      color: allPlayed
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // أزرار ٢٠٠ / ٤٠٠ / ٦٠٠
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3].map((level) {
                      final played = playedMap[level]!;
                      final canTap = canPlay && !played;

                      return GestureDetector(
                        onTap: canTap
                            ? () => onLevelTap(level)
                            : null,
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 200),
                          width: 38,
                          height: 28,
                          decoration: BoxDecoration(
                            color: played
                                ? AppColors.textHint
                                .withOpacity(0.15)
                                : canTap
                                ? teamColor.withOpacity(0.15)
                                : AppColors.surfaceColor
                                .withOpacity(0.5),
                            borderRadius:
                            BorderRadius.circular(20),
                            border: Border.all(
                              color: played
                                  ? AppColors.textHint
                                  .withOpacity(0.3)
                                  : canTap
                                  ? teamColor
                                  : AppColors.cardBorder
                                  .withOpacity(0.5),
                              width: canTap ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: played
                                ? Icon(
                              Icons.check_rounded,
                              color: AppColors.textHint,
                              size: 14,
                            )
                                : Text(
                              level == 1
                                  ? '٢٠٠'
                                  : level == 2
                                  ? '٤٠٠'
                                  : '٦٠٠',
                              style: TextStyle(
                                color: canTap
                                    ? teamColor
                                    : AppColors.textHint,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );

    // pulse animation للفئة المتاحة
    if (pulseAnimation != null && canPlay && !allPlayed) {
      return ScaleTransition(scale: pulseAnimation!, child: content);
    }
    return content;
  }
}