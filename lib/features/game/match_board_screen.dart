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
  final String challenge;

  const MatchBoardScreen({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.team1Categories,
    required this.team2Categories,
    this.challenge = 'normal',
  });

  @override
  State<MatchBoardScreen> createState() => _MatchBoardScreenState();
}

class _MatchBoardScreenState extends State<MatchBoardScreen>
    with TickerProviderStateMixin {

  int _team1Points = 0;
  int _team2Points = 0;
  int _currentTeam = 1;
  int _roundsPlayed = 0;
  bool _bonus1000Used = false;

  // ✅ حالة وسائل المساعدة — تحفظ عبر كل الأسئلة
  bool _team1CallUsed = false;
  bool _team1RevealUsed = false;
  bool _team1ExtendUsed = false;
  bool _team1AltUsed = false;
  bool _team2CallUsed = false;
  bool _team2RevealUsed = false;
  bool _team2ExtendUsed = false;
  bool _team2AltUsed = false;

  Map<String, Map<int, bool>> _playedMap = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentTeam = 1;

    for (final cat in [
      ...widget.team1Categories,
      ...widget.team2Categories,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.challenge != 'normal') {
        _showChallengeBanner();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showChallengeBanner() {
    final challenges = {
      'double_points':  ('⚡', 'نقطة مضاعفة', 'النقاط ×2 في أول جولة!'),
      'bonus_1000':     ('🌟', 'سؤال الألف', 'سيظهر سؤال 1000 نقطة في المنتصف!'),
      'time_pressure':  ('⏱️', 'ضغط الوقت', 'كل سؤال 15 ثانية فقط!'),
      'random_start':   ('🔀', 'ترتيب عشوائي', 'تم تحديد من يبدأ عشوائياً!'),
      'double_question':('💥', 'سؤال مزدوج', 'أول سؤال — الفريقان يتنافسان!'),
      'swap_categories':('🔁', 'عكس الأدوار', 'فريق 1 يجيب عن فئات فريق 2!'),
      'double_bet':     ('⏫', 'مضاعفة الرهان', 'قبل كل سؤال — راهن أو لا!'),
    };

    final data = challenges[widget.challenge];
    if (data == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorderGold, width: 2),
            boxShadow: [BoxShadow(color: AppColors.glowGold, blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data.$1, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(data.$2,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(data.$3,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('فاهمين، نبدأ! 🎮',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPlayed(String catId, int level) =>
      _playedMap[catId]?[level] ?? false;

  bool get _isGameOver {
    for (final cat in [
      ...widget.team1Categories,
      ...widget.team2Categories,
    ]) {
      for (int level = 1; level <= 3; level++) {
        if (!_isPlayed(cat.id, level)) return false;
      }
    }
    return true;
  }

  bool get _isDoubleQuestion =>
      widget.challenge == 'double_question' && _roundsPlayed == 0;

  int get _questionTime =>
      widget.challenge == 'time_pressure' ? 15 : 120;

  void _playCell(CategoryModel category, int level) async {
    if (_isPlayed(category.id, level)) return;

    if (_isDoubleQuestion) {
      await _showDoubleQuestionDialog(category, level);
      return;
    }

    bool isBetting = false;
    int betAmount = 0;
    if (widget.challenge == 'double_bet') {
      final bet = await _showBetDialog(category, level);
      if (bet != null) {
        isBetting = true;
        betAmount = bet;
      }
    }

    // ✅ نمرر حالة الوسائل للـ GameScreen
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(
          level: level,
          category: category,
          team1Name: widget.team1Name,
          team2Name: widget.team2Name,
          timeLimit: _questionTime,
          team1CallUsed: _team1CallUsed,
          team1RevealUsed: _team1RevealUsed,
          team1ExtendUsed: _team1ExtendUsed,
          team1AltUsed: _team1AltUsed,
          team2CallUsed: _team2CallUsed,
          team2RevealUsed: _team2RevealUsed,
          team2ExtendUsed: _team2ExtendUsed,
          team2AltUsed: _team2AltUsed,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        // ✅ نحفظ حالة الوسائل من النتيجة
        _team1CallUsed = result['team1CallUsed'] ?? _team1CallUsed;
        _team1RevealUsed = result['team1RevealUsed'] ?? _team1RevealUsed;
        _team1ExtendUsed = result['team1ExtendUsed'] ?? _team1ExtendUsed;
        _team1AltUsed = result['team1AltUsed'] ?? _team1AltUsed;
        _team2CallUsed = result['team2CallUsed'] ?? _team2CallUsed;
        _team2RevealUsed = result['team2RevealUsed'] ?? _team2RevealUsed;
        _team2ExtendUsed = result['team2ExtendUsed'] ?? _team2ExtendUsed;
        _team2AltUsed = result['team2AltUsed'] ?? _team2AltUsed;

        _playedMap[category.id]![level] = true;

        int t1 = result['team1'] ?? 0;
        int t2 = result['team2'] ?? 0;

        if (widget.challenge == 'double_points' && _roundsPlayed == 0) {
          t1 *= 2;
          t2 *= 2;
        }

        if (isBetting) {
          if (t1 > 0) {
            _team1Points += betAmount;
          } else if (t1 == 0 && _currentTeam == 1) {
            _team1Points -= betAmount;
            if (_team1Points < 0) _team1Points = 0;
          }
          if (t2 > 0) {
            _team2Points += betAmount;
          } else if (t2 == 0 && _currentTeam == 2) {
            _team2Points -= betAmount;
            if (_team2Points < 0) _team2Points = 0;
          }
        } else {
          _team1Points += t1;
          _team2Points += t2;
        }

        _roundsPlayed++;
        _currentTeam = _currentTeam == 1 ? 2 : 1;
      });

      final totalCells = (widget.team1Categories.length +
          widget.team2Categories.length) *
          3;
      final halfway = totalCells ~/ 2;
      if (widget.challenge == 'bonus_1000' &&
          _roundsPlayed == halfway &&
          !_bonus1000Used) {
        _bonus1000Used = true;
        await _showBonus1000Dialog();
      }

      if (_isGameOver) {
        Future.delayed(const Duration(milliseconds: 400), _showFinalResult);
      }
    }
  }

  Future<void> _showDoubleQuestionDialog(
      CategoryModel category, int level) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF8B2635), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💥', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('سؤال مزدوج!',
                  style: TextStyle(
                      color: Color(0xFF8B2635),
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('الفريقان يجيبان — الأسرع ياخذ النقاط كاملة',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B2635),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => GameScreen(
                        level: level,
                        category: category,
                        team1Name: widget.team1Name,
                        team2Name: widget.team2Name,
                        timeLimit: _questionTime,
                        isDoubleQuestion: true,
                        team1CallUsed: _team1CallUsed,
                        team1RevealUsed: _team1RevealUsed,
                        team1ExtendUsed: _team1ExtendUsed,
                        team1AltUsed: _team1AltUsed,
                        team2CallUsed: _team2CallUsed,
                        team2RevealUsed: _team2RevealUsed,
                        team2ExtendUsed: _team2ExtendUsed,
                        team2AltUsed: _team2AltUsed,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _team1CallUsed = result['team1CallUsed'] ?? _team1CallUsed;
                      _team1RevealUsed = result['team1RevealUsed'] ?? _team1RevealUsed;
                      _team1ExtendUsed = result['team1ExtendUsed'] ?? _team1ExtendUsed;
                      _team1AltUsed = result['team1AltUsed'] ?? _team1AltUsed;
                      _team2CallUsed = result['team2CallUsed'] ?? _team2CallUsed;
                      _team2RevealUsed = result['team2RevealUsed'] ?? _team2RevealUsed;
                      _team2ExtendUsed = result['team2ExtendUsed'] ?? _team2ExtendUsed;
                      _team2AltUsed = result['team2AltUsed'] ?? _team2AltUsed;

                      _playedMap[category.id]![level] = true;
                      _team1Points += (result['team1'] ?? 0) as int;
                      _team2Points += (result['team2'] ?? 0) as int;
                      _roundsPlayed++;
                      _currentTeam = _currentTeam == 1 ? 2 : 1;
                    });
                    if (_isGameOver) {
                      Future.delayed(
                          const Duration(milliseconds: 400), _showFinalResult);
                    }
                  }
                },
                child: const Text('ابدأ السؤال المزدوج! 💥',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBonus1000Dialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF9B59B6), width: 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF9B59B6).withOpacity(0.3),
                  blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌟', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text('سؤال الألف نقطة!',
                  style: TextStyle(
                      color: Color(0xFF9B59B6),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('سؤال مفاجئ من فئة عشوائية\nالفائز يأخذ 1000 نقطة!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B59B6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final allCats = [
                    ...widget.team1Categories,
                    ...widget.team2Categories,
                  ];
                  final randomCat =
                  allCats[DateTime.now().millisecond % allCats.length];
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => GameScreen(
                        level: 3,
                        category: randomCat,
                        team1Name: widget.team1Name,
                        team2Name: widget.team2Name,
                        timeLimit: 60,
                        bonusPoints: 1000,
                        team1CallUsed: _team1CallUsed,
                        team1RevealUsed: _team1RevealUsed,
                        team1ExtendUsed: _team1ExtendUsed,
                        team1AltUsed: _team1AltUsed,
                        team2CallUsed: _team2CallUsed,
                        team2RevealUsed: _team2RevealUsed,
                        team2ExtendUsed: _team2ExtendUsed,
                        team2AltUsed: _team2AltUsed,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _team1CallUsed = result['team1CallUsed'] ?? _team1CallUsed;
                      _team1RevealUsed = result['team1RevealUsed'] ?? _team1RevealUsed;
                      _team1ExtendUsed = result['team1ExtendUsed'] ?? _team1ExtendUsed;
                      _team1AltUsed = result['team1AltUsed'] ?? _team1AltUsed;
                      _team2CallUsed = result['team2CallUsed'] ?? _team2CallUsed;
                      _team2RevealUsed = result['team2RevealUsed'] ?? _team2RevealUsed;
                      _team2ExtendUsed = result['team2ExtendUsed'] ?? _team2ExtendUsed;
                      _team2AltUsed = result['team2AltUsed'] ?? _team2AltUsed;
                      _team1Points += (result['team1'] ?? 0) as int;
                      _team2Points += (result['team2'] ?? 0) as int;
                    });
                  }
                },
                child: const Text('ابدأ سؤال الألف! 🌟',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _showBetDialog(CategoryModel category, int level) async {
    final currentPoints = _currentTeam == 1 ? _team1Points : _team2Points;
    if (currentPoints == 0) return null;

    return showDialog<int>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏫', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                _currentTeam == 1 ? widget.team1Name : widget.team2Name,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('نقاطك الحالية: $currentPoints',
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 16),
              const Text(
                'تراهن بنقاطك؟\nإذا أجبت صح تضاعف — إذا غلط تخسرها',
                style: TextStyle(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('لا أراهن',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context, currentPoints),
                      child: const Text('أراهن! ⏫',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold)),
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

  void _showFinalResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          totalPoints: _team1Points + _team2Points,
          correctAnswers: 0,
          totalQuestions: (widget.team1Categories.length +
              widget.team2Categories.length) *
              3,
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
    int remaining = 0;
    for (final cat in [
      ...widget.team1Categories,
      ...widget.team2Categories,
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

            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorderGold),
                boxShadow: [
                  BoxShadow(color: AppColors.glowGold, blurRadius: 10),
                ],
              ),
              child: Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔵', style: TextStyle(fontSize: 14)),
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

                  Column(
                    children: [
                      const Text('VS',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('باقي $remaining',
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 10)),
                      if (widget.challenge != 'normal')
                        const SizedBox(height: 2),
                      if (widget.challenge != 'normal')
                        Text(_challengeEmoji(),
                            style: const TextStyle(fontSize: 14)),
                    ],
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔴', style: TextStyle(fontSize: 14)),
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  children: [

                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 5),
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
                          Expanded(
                            child: ListView.separated(
                              itemCount: widget.team1Categories.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final cat = widget.team1Categories[index];
                                final canPlay = _currentTeam == 1;
                                return _CategoryRow(
                                  category: cat,
                                  canPlay: canPlay,
                                  playedMap: _playedMap[cat.id]!,
                                  teamColor: AppColors.correct,
                                  pulseAnimation:
                                  canPlay ? _pulseAnimation : null,
                                  onLevelTap: (level) =>
                                      _playCell(cat, level),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

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

                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 5),
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
                                final cat = widget.team2Categories[index];
                                final canPlay = _currentTeam == 2;
                                return _CategoryRow(
                                  category: cat,
                                  canPlay: canPlay,
                                  playedMap: _playedMap[cat.id]!,
                                  teamColor: AppColors.wrong,
                                  pulseAnimation:
                                  canPlay ? _pulseAnimation : null,
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

  String _challengeEmoji() {
    const map = {
      'double_points': '⚡',
      'bonus_1000': '🌟',
      'time_pressure': '⏱️',
      'random_start': '🔀',
      'double_question': '💥',
      'swap_categories': '🔁',
      'double_bet': '⏫',
    };
    return map[widget.challenge] ?? '';
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
    final allPlayed = playedMap[1]! && playedMap[2]! && playedMap[3]!;

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
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceColor,
                  child: Center(
                    child: Text(category.emoji,
                        style: TextStyle(
                            fontSize: allPlayed ? 18 : 22)),
                  ),
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3].map((level) {
                      final played = playedMap[level]!;
                      final canTap = canPlay && !played;
                      return GestureDetector(
                        onTap: canTap ? () => onLevelTap(level) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 38,
                          height: 28,
                          decoration: BoxDecoration(
                            color: played
                                ? AppColors.textHint.withOpacity(0.15)
                                : canTap
                                ? teamColor.withOpacity(0.15)
                                : AppColors.surfaceColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: played
                                  ? AppColors.textHint.withOpacity(0.3)
                                  : canTap
                                  ? teamColor
                                  : AppColors.cardBorder.withOpacity(0.5),
                              width: canTap ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: played
                                ? Icon(Icons.check_rounded,
                                color: AppColors.textHint, size: 14)
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

    if (pulseAnimation != null && canPlay && !allPlayed) {
      return ScaleTransition(scale: pulseAnimation!, child: content);
    }
    return content;
  }
}