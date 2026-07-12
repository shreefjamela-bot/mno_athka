// ==============================
// شاشة لوحة المباراة — Luxury Theme
// ==============================

import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import 'game_screen.dart';
import 'result_screen.dart';

const _gold = Color(0xFFC49830);
const _goldLight = Color(0xFFF0D060);
const _goldDark = Color(0xFF6B4A10);
const _bg = Color(0xFF080808);
const _cardBg = Color(0xFF0E0E0E);
const _goldText = Color(0xFF5A4820);
const _team1Color = Color(0xFF2D7A5F);
const _team2Color = Color(0xFF8B2635);

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
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _currentTeam = 1;

    for (final cat in [...widget.team1Categories, ...widget.team2Categories]) {
      _playedMap[cat.id] = {1: false, 2: false, 3: false};
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.challenge != 'normal') _showChallengeBanner();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ===== Dialog الثيم الفاخر =====
  Widget _luxuryDialog({
    required String emoji,
    required String title,
    required String subtitle,
    required Color accentColor,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.6), width: 1),
          boxShadow: [BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 30)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 14),
            Text(title,
              style: TextStyle(fontFamily: 'Tajawal', color: accentColor, fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(subtitle,
              style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onPressed,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.8), accentColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(buttonText,
                    style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChallengeBanner() {
    final challenges = {
      'double_points': ('⚡', 'نقطة مضاعفة', 'النقاط ×2 في أول جولة!'),
      'bonus_1000': ('🌟', 'سؤال الألف', 'سيظهر سؤال 1000 نقطة عند أول سؤال 600!'),
      'time_pressure': ('⏱️', 'ضغط الوقت', 'كل سؤال 15 ثانية فقط!'),
      'double_bet': ('⏫', 'الرهان', 'راهن بنقاطك في أسئلة المستوى 600!'),
    };
    final data = challenges[widget.challenge];
    if (data == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _luxuryDialog(
        emoji: data.$1,
        title: data.$2,
        subtitle: data.$3,
        accentColor: _gold,
        buttonText: 'فاهمين، نبدأ! 🎮',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  bool _isPlayed(String catId, int level) => _playedMap[catId]?[level] ?? false;

  bool get _isGameOver {
    for (final cat in [...widget.team1Categories, ...widget.team2Categories]) {
      for (int level = 1; level <= 3; level++) {
        if (!_isPlayed(cat.id, level)) return false;
      }
    }
    return true;
  }

  int get _questionTime => widget.challenge == 'time_pressure' ? 15 : 120;

  void _playCell(CategoryModel category, int level) async {
    if (_isPlayed(category.id, level)) return;

    bool isBetting = false;
    int betAmount = 0;
    if (widget.challenge == 'double_bet' && level == 3) {
      final bet = await _showBetDialog();
      if (bet != null) { isBetting = true; betAmount = bet; }
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(
          level: level, category: category,
          team1Name: widget.team1Name, team2Name: widget.team2Name,
          timeLimit: _questionTime,
          team1CallUsed: _team1CallUsed, team1RevealUsed: _team1RevealUsed,
          team1ExtendUsed: _team1ExtendUsed, team1AltUsed: _team1AltUsed,
          team2CallUsed: _team2CallUsed, team2RevealUsed: _team2RevealUsed,
          team2ExtendUsed: _team2ExtendUsed, team2AltUsed: _team2AltUsed,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
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

        int t1 = result['team1'] ?? 0;
        int t2 = result['team2'] ?? 0;
        if (widget.challenge == 'double_points' && _roundsPlayed == 0) { t1 *= 2; t2 *= 2; }

        if (isBetting) {
          if (t1 > 0) _team1Points += betAmount;
          else if (t1 == 0 && _currentTeam == 1) { _team1Points -= betAmount; if (_team1Points < 0) _team1Points = 0; }
          if (t2 > 0) _team2Points += betAmount;
          else if (t2 == 0 && _currentTeam == 2) { _team2Points -= betAmount; if (_team2Points < 0) _team2Points = 0; }
        } else {
          _team1Points += t1;
          _team2Points += t2;
        }
        _roundsPlayed++;
        _currentTeam = _currentTeam == 1 ? 2 : 1;
      });

      if (widget.challenge == 'bonus_1000' && level == 3 && !_bonus1000Used) {
        _bonus1000Used = true;
        await _showBonus1000Dialog();
      }

      if (_isGameOver) Future.delayed(const Duration(milliseconds: 400), _showFinalResult);
    }
  }

  Future<void> _showBonus1000Dialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _luxuryDialog(
        emoji: '🌟',
        title: 'سؤال الألف نقطة!',
        subtitle: 'سؤال مفاجئ من فئة عشوائية\nالفائز يأخذ 1000 نقطة!',
        accentColor: const Color(0xFF9B59B6),
        buttonText: 'ابدأ سؤال الألف! 🌟',
        onPressed: () async {
          Navigator.pop(context);
          final allCats = [...widget.team1Categories, ...widget.team2Categories];
          final randomCat = allCats[DateTime.now().millisecond % allCats.length];
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => GameScreen(
                level: 3, category: randomCat,
                team1Name: widget.team1Name, team2Name: widget.team2Name,
                timeLimit: 60, bonusPoints: 1000,
                team1CallUsed: _team1CallUsed, team1RevealUsed: _team1RevealUsed,
                team1ExtendUsed: _team1ExtendUsed, team1AltUsed: _team1AltUsed,
                team2CallUsed: _team2CallUsed, team2RevealUsed: _team2RevealUsed,
                team2ExtendUsed: _team2ExtendUsed, team2AltUsed: _team2AltUsed,
              ),
              transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
          if (result != null && mounted) {
            setState(() {
              _team1Points += (result['team1'] ?? 0) as int;
              _team2Points += (result['team2'] ?? 0) as int;
            });
          }
        },
      ),
    );
  }

  Future<int?> _showBetDialog() async {
    final currentPoints = _currentTeam == 1 ? _team1Points : _team2Points;
    if (currentPoints == 0) return null;

    return showDialog<int>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _gold.withOpacity(0.5), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏫', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              Text(
                _currentTeam == 1 ? widget.team1Name : widget.team2Name,
                style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('نقاطك الحالية: $currentPoints',
                style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text('تراهن بنقاطك؟\nإذا أجبت صح تضاعف — إذا غلط تخسرها',
                style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, null),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(color: _gold.withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Text('لا أراهن',
                            style: TextStyle(fontFamily: 'Tajawal', color: _goldText, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, currentPoints),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3D2800), Color(0xFFB8890A), Color(0xFFE8C840), Color(0xFFB8890A), Color(0xFF3D2800)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: const Center(
                          child: Text('أراهن! ⏫',
                            style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF1A0E00), fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
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
          totalQuestions: (widget.team1Categories.length + widget.team2Categories.length) * 3,
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
    for (final cat in [...widget.team1Categories, ...widget.team2Categories]) {
      for (int level = 1; level <= 3; level++) {
        if (!_isPlayed(cat.id, level)) remaining++;
      }
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [

            // ===== هيدر النقاط =====
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withOpacity(0.35), width: 0.8),
                  boxShadow: [
                    BoxShadow(color: _gold.withOpacity(0.05 * _glowAnimation.value), blurRadius: 15),
                  ],
                ),
                child: Row(
                  children: [

                    // فريق ١
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: _team1Color)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(widget.team1Name,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    color: _currentTeam == 1 ? _team1Color : _goldText.withOpacity(0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [_goldLight, _gold],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text('$_team1Points',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Tajawal'),
                            ),
                          ),
                          if (_currentTeam == 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _team1Color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _team1Color.withOpacity(0.4)),
                              ),
                              child: const Text('دورك ✨',
                                style: TextStyle(fontFamily: 'Tajawal', color: _team1Color, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // وسط
                    Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [_goldLight, _gold],
                          ).createShader(bounds),
                          child: const Text('VS',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Tajawal', letterSpacing: 2),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('باقي $remaining',
                          style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 9),
                        ),
                        if (widget.challenge != 'normal') ...[
                          const SizedBox(height: 2),
                          Text(_challengeEmoji(), style: const TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),

                    // فريق ٢
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: _team2Color)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(widget.team2Name,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    color: _currentTeam == 2 ? _team2Color : _goldText.withOpacity(0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [_goldLight, _gold],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text('$_team2Points',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Tajawal'),
                            ),
                          ),
                          if (_currentTeam == 2)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _team2Color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _team2Color.withOpacity(0.4)),
                              ),
                              child: const Text('دورك ✨',
                                style: TextStyle(fontFamily: 'Tajawal', color: _team2Color, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== لوحة الفئات =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  children: [

                    // عمود فريق ١
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _currentTeam == 1 ? _team1Color.withOpacity(0.12) : _cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _currentTeam == 1 ? _team1Color.withOpacity(0.6) : _gold.withOpacity(0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Text('🔵 ${widget.team1Name}',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: _currentTeam == 1 ? _team1Color : _goldText.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: ListView.separated(
                              itemCount: widget.team1Categories.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final cat = widget.team1Categories[index];
                                return _CategoryRow(
                                  category: cat,
                                  canPlay: _currentTeam == 1,
                                  playedMap: _playedMap[cat.id]!,
                                  teamColor: _team1Color,
                                  pulseAnimation: _currentTeam == 1 ? _pulseAnimation : null,
                                  onLevelTap: (level) => _playCell(cat, level),
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
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _gold.withOpacity(0.4),
                            _gold,
                            _gold.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // عمود فريق ٢
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _currentTeam == 2 ? _team2Color.withOpacity(0.12) : _cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _currentTeam == 2 ? _team2Color.withOpacity(0.6) : _gold.withOpacity(0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Text('🔴 ${widget.team2Name}',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: _currentTeam == 2 ? _team2Color : _goldText.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: ListView.separated(
                              itemCount: widget.team2Categories.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final cat = widget.team2Categories[index];
                                return _CategoryRow(
                                  category: cat,
                                  canPlay: _currentTeam == 2,
                                  playedMap: _playedMap[cat.id]!,
                                  teamColor: _team2Color,
                                  pulseAnimation: _currentTeam == 2 ? _pulseAnimation : null,
                                  onLevelTap: (level) => _playCell(cat, level),
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
      'double_bet': '⏫',
    };
    return map[widget.challenge] ?? '';
  }
}

// ==============================
// صف الفئة — Luxury
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
        color: allPlayed ? const Color(0xFF0A0A0A) : _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allPlayed
              ? _gold.withOpacity(0.1)
              : canPlay
              ? teamColor.withOpacity(0.5)
              : _gold.withOpacity(0.15),
          width: canPlay && !allPlayed ? 0.8 : 0.5,
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
                errorBuilder: (_, __, ___) => _emojiBox(category.emoji, allPlayed),
              )
                  : _emojiBox(category.emoji, allPlayed),
            ),
          ),

          // اسم الفئة وأزرار المستويات
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                children: [
                  Text(category.title,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: allPlayed ? _goldText.withOpacity(0.3) : _goldLight.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3].map((level) {
                      final played = playedMap[level]!;
                      final canTap = canPlay && !played;
                      return GestureDetector(
                        onTap: canTap ? () => onLevelTap(level) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 26,
                          decoration: BoxDecoration(
                            color: played
                                ? _gold.withOpacity(0.05)
                                : canTap
                                ? teamColor.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: played
                                  ? _gold.withOpacity(0.15)
                                  : canTap
                                  ? teamColor.withOpacity(0.8)
                                  : _gold.withOpacity(0.1),
                              width: canTap ? 0.8 : 0.5,
                            ),
                          ),
                          child: Center(
                            child: played
                                ? Icon(Icons.check_rounded, color: _gold.withOpacity(0.3), size: 12)
                                : Text(
                              level == 1 ? '٢٠٠' : level == 2 ? '٤٠٠' : '٦٠٠',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: canTap ? teamColor : _goldText.withOpacity(0.2),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
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

  Widget _emojiBox(String emoji, bool dimmed) {
    return Container(
      color: _cardBg,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: dimmed ? 16 : 20)),
      ),
    );
  }
}