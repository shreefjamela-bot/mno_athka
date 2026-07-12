// ==============================
// شاشة اللعبة — Luxury Theme
// ==============================

import 'dart:async';
import 'dart:math';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/question_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/supabase_repository.dart';

const _gold = Color(0xFFC49830);
const _goldLight = Color(0xFFF0D060);
const _bg = Color(0xFF080808);
const _cardBg = Color(0xFF0E0E0E);
const _goldText = Color(0xFF5A4820);
const _team1Color = Color(0xFF2D7A5F);
const _team2Color = Color(0xFF8B2635);

class GameScreen extends StatefulWidget {
  final int level;
  final CategoryModel? category;
  final String team1Name;
  final String team2Name;
  final int timeLimit;
  final int bonusPoints;
  final bool isDoubleQuestion;
  final bool team1CallUsed;
  final bool team1RevealUsed;
  final bool team1ExtendUsed;
  final bool team1AltUsed;
  final bool team2CallUsed;
  final bool team2RevealUsed;
  final bool team2ExtendUsed;
  final bool team2AltUsed;

  const GameScreen({
    super.key,
    required this.level,
    this.category,
    this.team1Name = 'الفريق الأول',
    this.team2Name = 'الفريق الثاني',
    this.timeLimit = 120,
    this.bonusPoints = 0,
    this.isDoubleQuestion = false,
    this.team1CallUsed = false,
    this.team1RevealUsed = false,
    this.team1ExtendUsed = false,
    this.team1AltUsed = false,
    this.team2CallUsed = false,
    this.team2RevealUsed = false,
    this.team2ExtendUsed = false,
    this.team2AltUsed = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<QuestionModel> _questions = [];
  List<QuestionModel> _allQuestions = [];
  int _currentIndex = 0;
  int _team1Points = 0;
  int _team2Points = 0;
  late int _timeLeft;
  Timer? _timer;
  bool _isLoading = true;
  bool _timesUp = false;
  bool _showAnswer = false;
  String? _selectedTeam;

  late bool _team1CallUsed;
  late bool _team1RevealUsed;
  late bool _team1ExtendUsed;
  late bool _team1AltUsed;
  late bool _team2CallUsed;
  late bool _team2RevealUsed;
  late bool _team2ExtendUsed;
  late bool _team2AltUsed;

  String _revealedHint = '';
  String? _currentVideoUrl;
  int _videoViewId = 0;
  static int _videoCounter = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _questionController;
  late Animation<double> _questionFade;
  late Animation<Offset> _questionSlide;
  late AnimationController _pointsController;
  late Animation<double> _pointsFade;
  late Animation<double> _pointsScale;
  late AnimationController _timerController;
  late Animation<double> _timerGlow;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timeLimit;
    _team1CallUsed = widget.team1CallUsed;
    _team1RevealUsed = widget.team1RevealUsed;
    _team1ExtendUsed = widget.team1ExtendUsed;
    _team1AltUsed = widget.team1AltUsed;
    _team2CallUsed = widget.team2CallUsed;
    _team2RevealUsed = widget.team2RevealUsed;
    _team2ExtendUsed = widget.team2ExtendUsed;
    _team2AltUsed = widget.team2AltUsed;
    _initAnimations();
    _loadQuestions();
  }

  void _initAnimations() {
    _questionController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _questionFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _questionController, curve: Curves.easeOut));
    _questionSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _questionController, curve: Curves.easeOut));

    _pointsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pointsFade = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _pointsController, curve: Curves.easeOut));
    _pointsScale = Tween<double>(begin: 1, end: 2).animate(CurvedAnimation(parent: _pointsController, curve: Curves.easeOut));

    _timerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _timerGlow = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _timerController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _questionController.dispose();
    _pointsController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _registerVideo(String url) {
    _videoCounter++;
    _videoViewId = _videoCounter;
    ui.platformViewRegistry.registerViewFactory('game-video-$_videoViewId', (int id) {
      return html.VideoElement()
        ..src = url
        ..autoplay = true
        ..loop = true
        ..muted = true
        ..controls = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.borderRadius = '14px';
    });
    setState(() => _currentVideoUrl = url);
  }

  Future<void> _loadQuestions() async {
    final allQuestions = await SupabaseRepository.getQuestions(
      categoryId: widget.category?.id ?? 'general',
      level: widget.level,
    );
    setState(() {
      _allQuestions = allQuestions;
      if (allQuestions.isNotEmpty) {
        _questions = [allQuestions[Random().nextInt(allQuestions.length)]];
      }
      _isLoading = false;
    });
    if (_questions.isNotEmpty) {
      _questionController.forward();
      _startTimer();
      final videoUrl = _questions[_currentIndex].videoUrl;
      if (videoUrl != null && videoUrl.isNotEmpty) _registerVideo(videoUrl);
    }
  }

  void _startTimer() {
    _timeLeft = widget.timeLimit;
    _timesUp = false;
    _showAnswer = false;
    _selectedTeam = null;
    _revealedHint = '';
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) { _timeLeft--; }
        else { _timer?.cancel(); _timesUp = true; _showAnswer = true; }
      });
    });
  }

  Future<void> _playApplause() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/applause.wav'));
      await _audioPlayer.resume();
    } catch (e) { debugPrint('Audio error: $e'); }
  }

  int get _effectivePoints {
    if (widget.bonusPoints > 0) return widget.bonusPoints;
    return _questions.isNotEmpty ? _questions[_currentIndex].points : 0;
  }


  bool get _isAiChallenge => widget.category?.id == 'ai_challenge';

  void _selectWinner(String team) {
    if (_selectedTeam != null) return;
    _timer?.cancel();
    setState(() {
      _selectedTeam = team;
      _showAnswer = true;
      _timesUp = true;
      if (team == 'team1') { _team1Points += _effectivePoints; _pointsController.forward(from: 0); _playApplause(); }
      else if (team == 'team2') { _team2Points += _effectivePoints; _pointsController.forward(from: 0); _playApplause(); }
    });
  }

  void _goToResult() {
    _timer?.cancel();
    Navigator.pop(context, {
      'team1': _team1Points, 'team2': _team2Points,
      'team1CallUsed': _team1CallUsed, 'team1RevealUsed': _team1RevealUsed,
      'team1ExtendUsed': _team1ExtendUsed, 'team1AltUsed': _team1AltUsed,
      'team2CallUsed': _team2CallUsed, 'team2RevealUsed': _team2RevealUsed,
      'team2ExtendUsed': _team2ExtendUsed, 'team2AltUsed': _team2AltUsed,
    });
  }

  double get _timeProgress => _timeLeft / widget.timeLimit;

  Color get _timerColor {
    final ratio = _timeLeft / widget.timeLimit;
    if (ratio > 0.5) return _team1Color;
    if (ratio > 0.2) return _gold;
    return _team2Color;
  }

  void _resumeTimer() {
    if (_timesUp || _showAnswer || _selectedTeam != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) { _timeLeft--; }
        else { _timer?.cancel(); _timesUp = true; _showAnswer = true; }
      });
    });
  }

  // ===== ويدجت الصورة =====
  Widget _buildQuestionImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(height: 200, color: _cardBg,
            child: const Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 2))),
        errorWidget: (_, __, ___) => Container(height: 200, color: _cardBg,
            child: const Center(child: Icon(Icons.broken_image_outlined, color: _goldText, size: 40))),
      ),
    );
  }

  Widget _buildQuestionVideo() {
    if (_currentVideoUrl == null) {
      return Container(height: 200, decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14)),
          child: const Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 2)));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(height: 200, child: HtmlElementView(viewType: 'game-video-$_videoViewId')),
    );
  }

  Widget _buildAnswerImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url, width: double.infinity, fit: BoxFit.contain,
        placeholder: (_, __) => Container(height: 160, color: _cardBg,
            child: const Center(child: CircularProgressIndicator(color: _team1Color, strokeWidth: 2))),
        errorWidget: (_, __, ___) => const SizedBox(),
      ),
    );
  }

  // ===== وسائل المساعدة =====
  Widget _luxuryLifelineDialog({
    required String emoji,
    required String title,
    required Widget content,
    required Color accent,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontFamily: 'Tajawal', color: accent, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            content,
            const SizedBox(height: 18),
            GestureDetector(
              onTap: onPressed,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withOpacity(0.5)),
                ),
                child: Center(child: Text(buttonText,
                    style: TextStyle(fontFamily: 'Tajawal', color: accent, fontSize: 15, fontWeight: FontWeight.w700))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _useCall(String team) {
    if (team == 'team1' && _team1CallUsed) return;
    if (team == 'team2' && _team2CallUsed) return;
    setState(() { if (team == 'team1') _team1CallUsed = true; else _team2CallUsed = true; });
    _timer?.cancel();
    showDialog(context: context, builder: (_) => _luxuryLifelineDialog(
      emoji: '📞', title: 'اتصال بالجمهور', accent: _gold,
      content: Text('اختر شخصاً من الجمهور للمساعدة\nاستمع لرأيه ثم قرر',
          style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 13), textAlign: TextAlign.center),
      buttonText: 'تم الاتصال ✓',
      onPressed: () { Navigator.pop(context); if (!_timesUp) _resumeTimer(); },
    ));
  }

  void _useReveal(String team) {
    if (team == 'team1' && _team1RevealUsed) return;
    if (team == 'team2' && _team2RevealUsed) return;
    if (_questions.isEmpty) return;
    final answer = _questions[_currentIndex].answer ?? '';
    if (answer.isEmpty) return;
    setState(() {
      if (team == 'team1') _team1RevealUsed = true; else _team2RevealUsed = true;
      _revealedHint = 'أول حرف: ${answer.trimLeft()[0]}';
    });
    _timer?.cancel();
    showDialog(context: context, builder: (_) => _luxuryLifelineDialog(
      emoji: '🔍', title: 'كشف الحرف', accent: _team1Color,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(color: _team1Color.withOpacity(0.1), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _team1Color.withOpacity(0.5))),
        child: Text(answer.trimLeft()[0],
            style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 52, fontWeight: FontWeight.w900)),
      ),
      buttonText: 'فاهمين ✓',
      onPressed: () { Navigator.pop(context); if (!_timesUp) _resumeTimer(); },
    ));
  }

  void _useExtend(String team) {
    if (team == 'team1' && _team1ExtendUsed) return;
    if (team == 'team2' && _team2ExtendUsed) return;
    setState(() {
      if (team == 'team1') _team1ExtendUsed = true; else _team2ExtendUsed = true;
      _timeLeft += 30;
    });
    _timer?.cancel();
    showDialog(context: context, builder: (_) => _luxuryLifelineDialog(
      emoji: '⏳', title: 'تمديد الوقت!', accent: _gold,
      content: Text('أضفنا 30 ثانية\nالوقت الآن: $_timeLeft ث',
          style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 14), textAlign: TextAlign.center),
      buttonText: 'تمام ✓',
      onPressed: () { Navigator.pop(context); if (!_timesUp) _resumeTimer(); },
    ));
  }

  void _useAlt(String team) {
    if (team == 'team1' && _team1AltUsed) return;
    if (team == 'team2' && _team2AltUsed) return;
    if (_allQuestions.length < 2) return;
    setState(() {
      if (team == 'team1') _team1AltUsed = true; else _team2AltUsed = true;
      final others = _allQuestions.where((q) => q.id != _questions[_currentIndex].id).toList();
      if (others.isNotEmpty) {
        final newQ = others[Random().nextInt(others.length)];
        _questions = [newQ]; _currentIndex = 0; _revealedHint = ''; _currentVideoUrl = null;
        if (newQ.videoUrl != null && newQ.videoUrl!.isNotEmpty) _registerVideo(newQ.videoUrl!);
      }
    });
    _timer?.cancel();
    _questionController.reset();
    _questionController.forward();
    showDialog(context: context, builder: (_) => _luxuryLifelineDialog(
      emoji: '🔀', title: 'سؤال بديل!', accent: const Color(0xFF1A5F8A),
      content: Text('تم استبدال السؤال بسؤال جديد\nمن نفس الفئة والمستوى',
          style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 13), textAlign: TextAlign.center),
      buttonText: 'ابدأ السؤال الجديد ✓',
      onPressed: () { Navigator.pop(context); if (!_timesUp) _resumeTimer(); },
    ));
  }

  Widget _buildLifeline({required String emoji, required String label, required bool used, required VoidCallback onTap}) {
    return AbsorbPointer(
      absorbing: used || _selectedTeam != null,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(
            color: used ? _cardBg : _gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: used ? _gold.withOpacity(0.1) : _gold.withOpacity(0.4), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(used ? '✓' : emoji, style: TextStyle(fontSize: 11, color: used ? _goldText.withOpacity(0.3) : null)),
              const SizedBox(width: 3),
              Text(label, style: TextStyle(fontFamily: 'Tajawal', color: used ? _goldText.withOpacity(0.2) : _gold, fontSize: 9, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(color: _gold, strokeWidth: 2),
            const SizedBox(height: 16),
            Text('جاري تحميل السؤال...', style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 14)),
          ]),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('😕', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('ما في أسئلة لهذا المستوى', style: TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 18)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context, {'team1': 0, 'team2': 0,
                'team1CallUsed': _team1CallUsed, 'team1RevealUsed': _team1RevealUsed,
                'team1ExtendUsed': _team1ExtendUsed, 'team1AltUsed': _team1AltUsed,
                'team2CallUsed': _team2CallUsed, 'team2RevealUsed': _team2RevealUsed,
                'team2ExtendUsed': _team2ExtendUsed, 'team2AltUsed': _team2AltUsed}),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: _gold.withOpacity(0.4))),
                child: const Text('ارجع', style: TextStyle(fontFamily: 'Tajawal', color: _gold, fontSize: 16)),
              ),
            ),
          ]),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final hasQuestionImage = question.imageUrl != null && question.imageUrl!.isNotEmpty;
    final hasQuestionVideo = question.videoUrl != null && question.videoUrl!.isNotEmpty;
    final hasAnswerImage = question.answerImageUrl != null && question.answerImageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ===== هيدر =====
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showExitDialog,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _gold.withOpacity(0.3))),
                        child: Icon(Icons.close_rounded, color: _goldText.withOpacity(0.6), size: 18),
                      ),
                    ),
                    const Spacer(),
                    if (widget.bonusPoints > 0)
                      _labelChip('🌟 ${widget.bonusPoints} نقطة', const Color(0xFF9B59B6))
                    else
                      _labelChip(
                        '${widget.category?.emoji ?? '🎯'} ${widget.category?.title ?? 'عامة'}',
                        _gold,
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.timeLimit <= 15 ? _team2Color.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.timeLimit <= 15 ? '⏱️ ${widget.timeLimit}ث'
                            : 'سؤال ${widget.level == 1 ? "٢٠٠" : widget.level == 2 ? "٤٠٠" : "٦٠٠"}',
                        style: TextStyle(fontFamily: 'Tajawal',
                            color: widget.timeLimit <= 15 ? _team2Color : _goldText.withOpacity(0.6),
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ===== نقاط الفريقين =====
                Row(
                  children: [
                    Expanded(child: _teamCard('team1', widget.team1Name, _team1Points, _team1Color)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(colors: [_goldLight, _gold]).createShader(bounds),
                        child: const Text('VS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Tajawal', letterSpacing: 2)),
                      ),
                    ),
                    Expanded(child: _teamCard('team2', widget.team2Name, _team2Points, _team2Color)),
                  ],
                ),

                const SizedBox(height: 8),

                // ===== وسائل المساعدة =====
                Row(
                  children: [
                    Expanded(
                      child: Wrap(alignment: WrapAlignment.center, spacing: 3, runSpacing: 3, children: [
                        _buildLifeline(emoji: '📞', label: 'اتصال', used: _team1CallUsed, onTap: () => _useCall('team1')),
                        _buildLifeline(emoji: '🔍', label: 'حرف', used: _team1RevealUsed, onTap: () => _useReveal('team1')),
                        _buildLifeline(emoji: '⏳', label: '+30ث', used: _team1ExtendUsed, onTap: () => _useExtend('team1')),
                        _buildLifeline(emoji: '🔀', label: 'بديل', used: _team1AltUsed, onTap: () => _useAlt('team1')),
                      ]),
                    ),
                    Container(width: 0.5, height: 28, color: _gold.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 6)),
                    Expanded(
                      child: Wrap(alignment: WrapAlignment.center, spacing: 3, runSpacing: 3, children: [
                        _buildLifeline(emoji: '📞', label: 'اتصال', used: _team2CallUsed, onTap: () => _useCall('team2')),
                        _buildLifeline(emoji: '🔍', label: 'حرف', used: _team2RevealUsed, onTap: () => _useReveal('team2')),
                        _buildLifeline(emoji: '⏳', label: '+30ث', used: _team2ExtendUsed, onTap: () => _useExtend('team2')),
                        _buildLifeline(emoji: '🔀', label: 'بديل', used: _team2AltUsed, onTap: () => _useAlt('team2')),
                      ]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ===== شريط الوقت =====
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_effectivePoints نقطة',
                            style: const TextStyle(fontFamily: 'Tajawal', color: _gold, fontSize: 12, fontWeight: FontWeight.w700)),
                        if (_revealedHint.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: _team1Color.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _team1Color.withOpacity(0.4))),
                            child: Text(_revealedHint, style: const TextStyle(fontFamily: 'Tajawal', color: _team1Color, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        AnimatedBuilder(
                          animation: _timerGlow,
                          builder: (_, __) => Row(
                            children: [
                              Icon(_timesUp ? Icons.timer_off_outlined : Icons.timer_outlined,
                                  color: _timesUp ? _team2Color : _timerColor, size: 13),
                              const SizedBox(width: 4),
                              Text(_timesUp ? 'انتهى الوقت!' : '$_timeLeft ث',
                                  style: TextStyle(fontFamily: 'Tajawal',
                                      color: _timesUp ? _team2Color : _timerColor,
                                      fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _timeProgress,
                        backgroundColor: _gold.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(_timesUp ? _team2Color : _timerColor),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ===== صورة/فيديو السؤال =====
                if (hasQuestionVideo) _buildQuestionVideo()
                else if (hasQuestionImage) _buildQuestionImage(question.imageUrl!),

                if (hasQuestionVideo || hasQuestionImage) const SizedBox(height: 12),

                // ===== بطاقة السؤال =====
                FadeTransition(
                  opacity: _questionFade,
                  child: SlideTransition(
                    position: _questionSlide,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.bonusPoints > 0
                              ? const Color(0xFF9B59B6).withOpacity(0.6)
                              : _timesUp ? _gold.withOpacity(0.6) : _gold.withOpacity(0.3),
                          width: 0.8,
                        ),
                        boxShadow: [BoxShadow(color: _gold.withOpacity(_timesUp ? 0.1 : 0.05), blurRadius: 20)],
                      ),
                      child: Text(question.question,
                        style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 20, fontWeight: FontWeight.w700, height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),


                // ===== تعليمات تحدي الذكاء =====
                if (_isAiChallenge && !_showAnswer) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.5), width: 1),
                    ),
                    child: Column(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        const Text(
                          'تحدي الذكاء الاصطناعي',
                          style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF9B59B6), fontSize: 16, fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 0.5,
                          color: const Color(0xFF9B59B6).withOpacity(0.3),
                        ),
                        const SizedBox(height: 10),
                        _aiStep('١', 'افتح Claude أو أي أداة AI على هاتفك'),
                        const SizedBox(height: 6),
                        _aiStep('٢', 'انسخ البرومبت أعلاه وولّد الصورة'),
                        const SizedBox(height: 6),
                        _aiStep('٣', 'اعرض صورتك للمقدم والجمهور'),
                        const SizedBox(height: 6),
                        _aiStep('٤', 'المقدم يحكم من الصورة الأجمل'),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // ===== الإجابة الصحيحة =====
                if (_showAnswer)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _team1Color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _team1Color.withOpacity(0.5), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: _team1Color.withOpacity(0.2),
                                  border: Border.all(color: _team1Color.withOpacity(0.5))),
                              child: Icon(Icons.check_rounded, color: _team1Color, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('الإجابة الصحيحة',
                                      style: TextStyle(fontFamily: 'Tajawal', color: _team1Color.withOpacity(0.7), fontSize: 10, letterSpacing: 1)),
                                  const SizedBox(height: 3),
                                  Text(question.answer ?? '—',
                                      style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 16, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (hasAnswerImage) ...[const SizedBox(height: 12), _buildAnswerImage(question.answerImageUrl!)],
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                // ===== أزرار الفريقين =====
                if (_selectedTeam == null) ...[
                  Text(_showAnswer ? 'من أجاب صح؟' : 'اضغط على الفريق الذي أجاب',
                      style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _winnerBtn('team1', widget.team1Name, _team1Color)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _selectWinner('none'),
                        child: Container(
                          width: 48, height: 52,
                          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _gold.withOpacity(0.2))),
                          child: Center(child: Text('—', style: TextStyle(color: _goldText.withOpacity(0.4), fontSize: 18))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _winnerBtn('team2', widget.team2Name, _team2Color)),
                    ],
                  ),
                ],

                if (_selectedTeam != null)
                  GestureDetector(
                    onTap: _goToResult,
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3D2800), Color(0xFFB8890A), Color(0xFFE8C840), Color(0xFFB8890A), Color(0xFF3D2800)],
                          begin: Alignment.centerLeft, end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 15)],
                      ),
                      child: const Center(
                        child: Text('ارجع للوحة 🎯',
                            style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF1A0E00), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _teamCard(String teamId, String name, int points, Color color) {
    final isSelected = _selectedTeam == teamId;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : color.withOpacity(0.3), width: isSelected ? 1 : 0.5),
          ),
          child: Column(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(height: 4),
              Text(name, style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 10, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, maxLines: 1),
              const SizedBox(height: 2),
              Text('$points', style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        if (_pointsController.isAnimating && _selectedTeam == teamId)
          Positioned(
            top: -20, left: 0, right: 0,
            child: FadeTransition(
              opacity: _pointsFade,
              child: ScaleTransition(
                scale: _pointsScale,
                child: Text('+$_effectivePoints',
                    style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 18, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center),
              ),
            ),
          ),
      ],
    );
  }

  Widget _winnerBtn(String teamId, String name, Color color) {
    return GestureDetector(
      onTap: () => _selectWinner(teamId),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.6), width: 0.8),
        ),
        child: Center(
          child: Text(name,
              style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 13, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _labelChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(text, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }


  Widget _aiStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF9B59B6).withOpacity(0.15),
            border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.5)),
          ),
          child: Center(
            child: Text(number, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF9B59B6), fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  void _showExitDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardBg, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _gold.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              const Text('مغادرة السؤال؟',
                  style: TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('سيتم فقدان تقدمك الحالي',
                  style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () { Navigator.pop(context); if (!_timesUp && !_showAnswer) _resumeTimer(); },
                      child: Container(height: 46,
                        decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(23),
                            border: Border.all(color: _gold.withOpacity(0.3))),
                        child: const Center(child: Text('تابع', style: TextStyle(fontFamily: 'Tajawal', color: _gold, fontSize: 14))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, {
                          'team1': _team1Points, 'team2': _team2Points,
                          'team1CallUsed': _team1CallUsed, 'team1RevealUsed': _team1RevealUsed,
                          'team1ExtendUsed': _team1ExtendUsed, 'team1AltUsed': _team1AltUsed,
                          'team2CallUsed': _team2CallUsed, 'team2RevealUsed': _team2RevealUsed,
                          'team2ExtendUsed': _team2ExtendUsed, 'team2AltUsed': _team2AltUsed,
                        });
                      },
                      child: Container(height: 46,
                        decoration: BoxDecoration(color: _team2Color.withOpacity(0.15), borderRadius: BorderRadius.circular(23),
                            border: Border.all(color: _team2Color.withOpacity(0.5))),
                        child: const Center(child: Text('خروج', style: TextStyle(fontFamily: 'Tajawal', color: _team2Color, fontSize: 14, fontWeight: FontWeight.w700))),
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
}