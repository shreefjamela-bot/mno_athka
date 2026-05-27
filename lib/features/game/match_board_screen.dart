// ==============================
// شاشة لوحة المباراة — Premium Design
// اسم الملف: match_board_screen.dart
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';
import 'game_screen.dart';

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
  Set<String> _playedCategories = {};
  int _currentLevel = 1;
  int _currentTeam = 1;
  int _questionsInLevel = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int _getLevelPoints() {
    if (_currentLevel == 1) return 200;
    if (_currentLevel == 2) return 400;
    return 600;
  }

  Color _getLevelColor() {
    if (_currentLevel == 1) return AppColors.level1;
    if (_currentLevel == 2) return AppColors.level2;
    return AppColors.level3;
  }

  bool _isPlayed(String categoryId) =>
      _playedCategories.contains('${categoryId}_$_currentLevel');

  void _playCategory(CategoryModel category) async {
    final result = await Navigator.push<Map<String, int>>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(
          level: _currentLevel,
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
        _playedCategories.add('${category.id}_$_currentLevel');
        _questionsInLevel++;
        _team1Points += result['team1'] ?? 0;
        _team2Points += result['team2'] ?? 0;
        _currentTeam = _currentTeam == 1 ? 2 : 1;
        _checkLevelComplete();
      });
    }
  }

  void _checkLevelComplete() {
    final all = [
      ...widget.team1Categories,
      ...widget.team2Categories,
    ];
    final allPlayed = all.every((c) => _isPlayed(c.id));

    if (allPlayed) {
      if (_currentLevel < 3) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _currentLevel++;
              _questionsInLevel = 0;
              _currentTeam = 1;
            });
            _showLevelUpDialog();
          }
        });
      } else {
        Future.delayed(
            const Duration(milliseconds: 300), _showFinalResult);
      }
    }
  }

  void _showLevelUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorderGold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentLevel == 2 ? '🟡' : '🔴',
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
              ).createShader(bounds),
              child: Text(
                'المستوى $_currentLevel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_getLevelPoints()} نقطة لكل سؤال',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  const Text('🔵', style: TextStyle(fontSize: 20)),
                  Text('$_team1Points',
                      style: const TextStyle(
                          color: AppColors.correct,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ]),
                Column(children: [
                  const Text('🔴', style: TextStyle(fontSize: 20)),
                  Text('$_team2Points',
                      style: const TextStyle(
                          color: AppColors.wrong,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ابدأ المستوى ←',
                  style: TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalResult() {
    final winner = _team1Points > _team2Points
        ? widget.team1Name
        : _team2Points > _team1Points
        ? widget.team2Name
        : 'تعادل';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
              color: AppColors.cardBorderGold, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
              ).createShader(bounds),
              child: const Text('انتهت المباراة!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  const Text('🔵', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(widget.team1Name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$_team1Points',
                      style: const TextStyle(
                          color: AppColors.correct,
                          fontSize: 36,
                          fontWeight: FontWeight.bold)),
                  if (winner == widget.team1Name)
                    const Text('🏆 فائز',
                        style: TextStyle(
                            color: AppColors.correct,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                ]),
                Text('VS',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Column(children: [
                  const Text('🔴', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(widget.team2Name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$_team2Points',
                      style: const TextStyle(
                          color: AppColors.wrong,
                          fontSize: 36,
                          fontWeight: FontWeight.bold)),
                  if (winner == widget.team2Name)
                    const Text('🏆 فائز',
                        style: TextStyle(
                            color: AppColors.correct,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: AppColors.glowGold, blurRadius: 15)
                ],
              ),
              child: Text(
                winner == 'تعادل' ? '🤝 تعادل!' : '🎉 مبروك $winner!',
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('🏠 الرئيسية',
                  style: TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = [
      ...widget.team1Categories,
      ...widget.team2Categories,
    ];
    final remaining = allCategories.where((c) => !_isPlayed(c.id)).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // الهيدر — النقاط
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorderGold),
                boxShadow: [
                  BoxShadow(color: AppColors.glowGold, blurRadius: 10)
                ],
              ),
              child: Row(
                children: [

                  // الفريق ١
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔵',
                                style: TextStyle(fontSize: 16)),
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
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(colors: [
                                AppColors.primaryLight,
                                AppColors.correct
                              ]).createShader(bounds),
                          child: Text('$_team1Points',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLevelColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _getLevelColor(), width: 1),
                        ),
                        child: Text('مستوى $_currentLevel',
                            style: TextStyle(
                                color: _getLevelColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text('${_getLevelPoints()} ⭐',
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('باقي $remaining',
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 10)),
                    ],
                  ),

                  // الفريق ٢
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔴',
                                style: TextStyle(fontSize: 16)),
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
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(colors: [
                                AppColors.primaryLight,
                                AppColors.wrong
                              ]).createShader(bounds),
                          child: Text('$_team2Points',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
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
            // شريط المستويات الثلاثة
            // ==============================
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [

                  // المستوى ١
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentLevel == 1
                            ? AppColors.level1.withOpacity(0.2)
                            : _currentLevel > 1
                            ? AppColors.surfaceColor.withOpacity(0.3)
                            : AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _currentLevel == 1
                              ? AppColors.level1
                              : _currentLevel > 1
                              ? AppColors.textHint.withOpacity(0.3)
                              : AppColors.cardBorder,
                          width: _currentLevel == 1 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('🟢',
                              style: TextStyle(
                                  fontSize:
                                  _currentLevel == 1 ? 18 : 14)),
                          const SizedBox(height: 2),
                          Text('٢٠٠',
                              style: TextStyle(
                                color: _currentLevel == 1
                                    ? AppColors.level1
                                    : _currentLevel > 1
                                    ? AppColors.textHint
                                    : AppColors.textSecondary,
                                fontSize:
                                _currentLevel == 1 ? 14 : 11,
                                fontWeight: _currentLevel == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                          if (_currentLevel == 1)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 20, height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.level1,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          if (_currentLevel > 1)
                            const Icon(Icons.check_rounded,
                                color: AppColors.textHint, size: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // المستوى ٢
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentLevel == 2
                            ? AppColors.level2.withOpacity(0.2)
                            : _currentLevel > 2
                            ? AppColors.surfaceColor.withOpacity(0.3)
                            : AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _currentLevel == 2
                              ? AppColors.level2
                              : _currentLevel > 2
                              ? AppColors.textHint.withOpacity(0.3)
                              : AppColors.cardBorder,
                          width: _currentLevel == 2 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('🟡',
                              style: TextStyle(
                                  fontSize:
                                  _currentLevel == 2 ? 18 : 14)),
                          const SizedBox(height: 2),
                          Text('٤٠٠',
                              style: TextStyle(
                                color: _currentLevel == 2
                                    ? AppColors.level2
                                    : _currentLevel > 2
                                    ? AppColors.textHint
                                    : AppColors.textSecondary,
                                fontSize:
                                _currentLevel == 2 ? 14 : 11,
                                fontWeight: _currentLevel == 2
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                          if (_currentLevel == 2)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 20, height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.level2,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          if (_currentLevel > 2)
                            const Icon(Icons.check_rounded,
                                color: AppColors.textHint, size: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // المستوى ٣
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentLevel == 3
                            ? AppColors.level3.withOpacity(0.2)
                            : AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _currentLevel == 3
                              ? AppColors.level3
                              : AppColors.cardBorder,
                          width: _currentLevel == 3 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('🔴',
                              style: TextStyle(
                                  fontSize:
                                  _currentLevel == 3 ? 18 : 14)),
                          const SizedBox(height: 2),
                          Text('٦٠٠',
                              style: TextStyle(
                                color: _currentLevel == 3
                                    ? AppColors.level3
                                    : AppColors.textSecondary,
                                fontSize:
                                _currentLevel == 3 ? 14 : 11,
                                fontWeight: _currentLevel == 3
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                          if (_currentLevel == 3)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 20, height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.level3,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // اللوحة الرئيسية — عمودين
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // عمود الفريق ١
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _currentTeam == 1
                                  ? AppColors.correct.withOpacity(0.2)
                                  : AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
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
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: widget.team1Categories.length,
                              itemBuilder: (context, index) {
                                final cat =
                                widget.team1Categories[index];
                                final played = _isPlayed(cat.id);
                                final canPlay =
                                    _currentTeam == 1 && !played;
                                return _BoardCategoryCard(
                                  category: cat,
                                  isPlayed: played,
                                  canPlay: canPlay,
                                  teamColor: AppColors.correct,
                                  pulseAnimation:
                                  canPlay ? _pulseAnimation : null,
                                  onTap: canPlay
                                      ? () => _playCategory(cat)
                                      : null,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // فاصل عمودي
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
                            const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _currentTeam == 2
                                  ? AppColors.wrong.withOpacity(0.2)
                                  : AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
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
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: widget.team2Categories.length,
                              itemBuilder: (context, index) {
                                final cat =
                                widget.team2Categories[index];
                                final played = _isPlayed(cat.id);
                                final canPlay =
                                    _currentTeam == 2 && !played;
                                return _BoardCategoryCard(
                                  category: cat,
                                  isPlayed: played,
                                  canPlay: canPlay,
                                  teamColor: AppColors.wrong,
                                  pulseAnimation:
                                  canPlay ? _pulseAnimation : null,
                                  onTap: canPlay
                                      ? () => _playCategory(cat)
                                      : null,
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

            // شريط التقدم
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(width: 8, height: 8,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentLevel >= 1
                                    ? AppColors.level1
                                    : AppColors.textHint)),
                        const SizedBox(width: 4),
                        Container(width: 8, height: 8,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentLevel >= 2
                                    ? AppColors.level2
                                    : AppColors.textHint)),
                        const SizedBox(width: 4),
                        Container(width: 8, height: 8,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentLevel >= 3
                                    ? AppColors.level3
                                    : AppColors.textHint)),
                      ]),
                      Text(
                          '${_questionsInLevel + ((_currentLevel - 1) * 8)} / 24 سؤال',
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_questionsInLevel +
                          ((_currentLevel - 1) * 8)) /
                          24,
                      backgroundColor: AppColors.surfaceColor,
                      valueColor:
                      AlwaysStoppedAnimation(_getLevelColor()),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _BoardCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isPlayed;
  final bool canPlay;
  final Color teamColor;
  final Animation<double>? pulseAnimation;
  final VoidCallback? onTap;

  const _BoardCategoryCard({
    required this.category,
    required this.isPlayed,
    required this.canPlay,
    required this.teamColor,
    this.pulseAnimation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isPlayed
              ? AppColors.surfaceColor.withOpacity(0.5)
              : canPlay
              ? teamColor.withOpacity(0.12)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlayed
                ? AppColors.textHint.withOpacity(0.3)
                : canPlay
                ? teamColor
                : AppColors.cardBorder,
            width: canPlay ? 2 : 1,
          ),
          boxShadow: canPlay
              ? [BoxShadow(
              color: teamColor.withOpacity(0.3),
              blurRadius: 8)]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: category.imageUrl != null
                          ? Image.network(
                        category.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(category.emoji,
                              style: TextStyle(
                                  fontSize:
                                  isPlayed ? 20 : 26)),
                        ),
                      )
                          : Center(
                        child: Text(category.emoji,
                            style: TextStyle(
                                fontSize: isPlayed ? 20 : 26)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.title,
                    style: TextStyle(
                      color: isPlayed
                          ? AppColors.textHint
                          : canPlay
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: canPlay
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isPlayed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textHint.withOpacity(0.3),
                        border: Border.all(
                            color: AppColors.textHint, width: 1),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.textHint, size: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (pulseAnimation != null && canPlay) {
      return ScaleTransition(scale: pulseAnimation!, child: card);
    }
    return card;
  }
}