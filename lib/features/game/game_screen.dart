// ==============================
// شاشة اللعبة — Open Question System
// اسم الملف: game_screen.dart
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
import '../../core/constants/app_colors.dart';
import '../../data/models/question_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/supabase_repository.dart';

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

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {

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
  bool _doubleQuestionAnswered = false;

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
    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _questionFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _questionController, curve: Curves.easeOut),
    );
    _questionSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _questionController, curve: Curves.easeOut));

    _pointsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pointsFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
          parent: _pointsController, curve: Curves.easeOut),
    );
    _pointsScale = Tween<double>(begin: 1, end: 1.8).animate(
      CurvedAnimation(
          parent: _pointsController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _questionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _registerVideo(String url) {
    _videoCounter++;
    _videoViewId = _videoCounter;
    final viewType = 'game-video-$_videoViewId';
    ui.platformViewRegistry.registerViewFactory(
      viewType,
          (int id) {
        final video = html.VideoElement()
          ..src = url
          ..autoplay = true
          ..loop = true
          ..muted = true
          ..controls = true
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover'
          ..style.borderRadius = '16px';
        return video;
      },
    );
    setState(() => _currentVideoUrl = url);
  }

  Future<void> _loadQuestions() async {
    final allQuestions = await SupabaseRepository.getQuestions(
      categoryId: widget.category?.id ?? 'general',
      level: widget.level,
    );

    setState(() {
      _allQuestions = allQuestions;
      if (allQuestions.isEmpty) {
        _questions = [];
      } else {
        final random = Random();
        final picked =
        allQuestions[random.nextInt(allQuestions.length)];
        _questions = [picked];
      }
      _isLoading = false;
    });

    if (_questions.isNotEmpty) {
      _questionController.forward();
      _startTimer();
      final videoUrl = _questions[_currentIndex].videoUrl;
      if (videoUrl != null && videoUrl.isNotEmpty) {
        _registerVideo(videoUrl);
      }
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
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _timesUp = true;
          _showAnswer = true;
        }
      });
    });
  }

  Future<void> _playApplause() async {
    try {
      await _audioPlayer
          .setSource(AssetSource('sounds/applause.wav'));
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  int get _effectivePoints {
    if (widget.bonusPoints > 0) return widget.bonusPoints;
    return _questions.isNotEmpty
        ? _questions[_currentIndex].points
        : 0;
  }

  void _selectWinner(String team) {
    if (_selectedTeam != null) return;
    if (widget.isDoubleQuestion && !_doubleQuestionAnswered) {
      _doubleQuestionAnswered = true;
    }
    _timer?.cancel();
    setState(() {
      _selectedTeam = team;
      _showAnswer = true;
      _timesUp = true;
      final points = _effectivePoints;
      if (team == 'team1') {
        _team1Points += points;
        _pointsController.forward(from: 0);
        _playApplause();
      } else if (team == 'team2') {
        _team2Points += points;
        _pointsController.forward(from: 0);
        _playApplause();
      }
    });
  }

  void _goToResult() {
    _timer?.cancel();
    Navigator.pop(context, {
      'team1': _team1Points,
      'team2': _team2Points,
      'team1CallUsed': _team1CallUsed,
      'team1RevealUsed': _team1RevealUsed,
      'team1ExtendUsed': _team1ExtendUsed,
      'team1AltUsed': _team1AltUsed,
      'team2CallUsed': _team2CallUsed,
      'team2RevealUsed': _team2RevealUsed,
      'team2ExtendUsed': _team2ExtendUsed,
      'team2AltUsed': _team2AltUsed,
    });
  }

  double get _timeProgress => _timeLeft / widget.timeLimit;

  Color get _timerColor {
    final ratio = _timeLeft / widget.timeLimit;
    if (ratio > 0.5) return AppColors.correct;
    if (ratio > 0.2) return AppColors.primary;
    return AppColors.wrong;
  }

  void _resumeTimer() {
    if (_timesUp || _showAnswer || _selectedTeam != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _timesUp = true;
          _showAnswer = true;
        }
      });
    });
  }

  // ── ويدجت الصورة (كاملة بدون قص) ────────────
  Widget _buildQuestionImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(
          height: 200,
          color: AppColors.surfaceColor,
          child: const Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 200,
          color: AppColors.surfaceColor,
          child: const Center(
            child: Icon(Icons.broken_image_outlined,
                color: AppColors.textHint, size: 40),
          ),
        ),
      ),
    );
  }

  // ── ويدجت الفيديو HTML ───────────────────────
  Widget _buildQuestionVideo() {
    if (_currentVideoUrl == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child:
        HtmlElementView(viewType: 'game-video-$_videoViewId'),
      ),
    );
  }

  // ── ويدجت صورة الإجابة (كاملة بدون قص) ──────
  Widget _buildAnswerImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(
          height: 160,
          color: AppColors.surfaceColor,
          child: const Center(
            child: CircularProgressIndicator(
                color: AppColors.correct, strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => const SizedBox(),
      ),
    );
  }

  // ══════════════════════════════════════
  // وسائل المساعدة
  // ══════════════════════════════════════

  void _useCall(String team) {
    if (team == 'team1' && _team1CallUsed) return;
    if (team == 'team2' && _team2CallUsed) return;
    setState(() {
      if (team == 'team1') _team1CallUsed = true;
      else _team2CallUsed = true;
    });
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border:
            Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                  color: AppColors.glowGold, blurRadius: 20)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📞',
                  style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                team == 'team1'
                    ? widget.team1Name
                    : widget.team2Name,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'اختر شخصاً من الجمهور للمساعدة\nاستمع لرأيه ثم قرر',
                style: TextStyle(
                    color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (!_timesUp) _resumeTimer();
                },
                child: const Text('تم الاتصال ✓',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _useReveal(String team) {
    if (team == 'team1' && _team1RevealUsed) return;
    if (team == 'team2' && _team2RevealUsed) return;
    if (_questions.isEmpty) return;
    final answer = _questions[_currentIndex].answer ?? '';
    if (answer.isEmpty) return;
    setState(() {
      if (team == 'team1') _team1RevealUsed = true;
      else _team2RevealUsed = true;
      final firstChar = answer.trimLeft()[0];
      _revealedHint = 'أول حرف: $firstChar';
    });
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF2D7A5F), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔍',
                  style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('كشف الحرف',
                  style: TextStyle(
                      color: Color(0xFF2D7A5F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D7A5F)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF2D7A5F),
                      width: 2),
                ),
                child: Text(
                  answer.trimLeft()[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D7A5F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (!_timesUp) _resumeTimer();
                },
                child: const Text('فاهمين ✓',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _useExtend(String team) {
    if (team == 'team1' && _team1ExtendUsed) return;
    if (team == 'team2' && _team2ExtendUsed) return;
    setState(() {
      if (team == 'team1') _team1ExtendUsed = true;
      else _team2ExtendUsed = true;
      _timeLeft += 30;
    });
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFFFFD700), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏳',
                  style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('تمديد الوقت!',
                  style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'أضفنا 30 ثانية\nالوقت الآن: $_timeLeft ث',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (!_timesUp) _resumeTimer();
                },
                child: const Text('تمام ✓',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _useAlt(String team) {
    if (team == 'team1' && _team1AltUsed) return;
    if (team == 'team2' && _team2AltUsed) return;
    if (_allQuestions.length < 2) return;
    setState(() {
      if (team == 'team1') _team1AltUsed = true;
      else _team2AltUsed = true;
      final current = _questions[_currentIndex];
      final others = _allQuestions
          .where((q) => q.id != current.id)
          .toList();
      if (others.isNotEmpty) {
        final random = Random();
        final newQ = others[random.nextInt(others.length)];
        _questions = [newQ];
        _currentIndex = 0;
        _revealedHint = '';
        _currentVideoUrl = null;
        final videoUrl = newQ.videoUrl;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _registerVideo(videoUrl);
        }
      }
    });
    _timer?.cancel();
    _questionController.reset();
    _questionController.forward();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF1A5F8A), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔀',
                  style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('سؤال بديل!',
                  style: TextStyle(
                      color: Color(0xFF1A5F8A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'تم استبدال السؤال بسؤال جديد\nمن نفس الفئة والمستوى',
                style: TextStyle(
                    color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5F8A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (!_timesUp) _resumeTimer();
                },
                child: const Text('ابدأ السؤال الجديد ✓',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifeline({
    required String emoji,
    required String label,
    required bool used,
    required VoidCallback onTap,
  }) {
    return AbsorbPointer(
      absorbing: used || _selectedTeam != null,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color:
            used ? Colors.white10 : AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: used
                  ? Colors.white12
                  : AppColors.cardBorderGold,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                used ? '✓' : emoji,
                style: TextStyle(
                  fontSize: 12,
                  color: used ? Colors.white24 : null,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  color: used
                      ? Colors.white24
                      : AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        backgroundColor: AppColors.background,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
              SizedBox(height: 16),
              Text('جاري تحميل الأسئلة...',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕',
                  style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text('ما في أسئلة لهذا المستوى',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, {
                  'team1': _team1Points,
                  'team2': _team2Points,
                  'team1CallUsed': _team1CallUsed,
                  'team1RevealUsed': _team1RevealUsed,
                  'team1ExtendUsed': _team1ExtendUsed,
                  'team1AltUsed': _team1AltUsed,
                  'team2CallUsed': _team2CallUsed,
                  'team2RevealUsed': _team2RevealUsed,
                  'team2ExtendUsed': _team2ExtendUsed,
                  'team2AltUsed': _team2AltUsed,
                }),
                child: const Text('ارجع'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final size = MediaQuery.of(context).size;
    final hasQuestionImage = question.imageUrl != null &&
        question.imageUrl!.isNotEmpty;
    final hasQuestionVideo = question.videoUrl != null &&
        question.videoUrl!.isNotEmpty;
    final hasAnswerImage = question.answerImageUrl != null &&
        question.answerImageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [

            ...List.generate(6, (i) {
              final random = Random(i);
              return Positioned(
                top: random.nextDouble() * size.height,
                left: random.nextDouble() * size.width,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
              );
            }),

            SingleChildScrollView(
              child: Column(
                children: [

                  // ── الهيدر ──────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showExitDialog,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius:
                              BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.cardBorder),
                            ),
                            child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 18),
                          ),
                        ),
                        const Spacer(),
                        if (widget.isDoubleQuestion)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B2635)
                                  .withOpacity(0.2),
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF8B2635),
                                  width: 1.5),
                            ),
                            child: const Text('💥 سؤال مزدوج',
                                style: TextStyle(
                                    color: Color(0xFF8B2635),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          )
                        else if (widget.bonusPoints > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B59B6)
                                  .withOpacity(0.2),
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF9B59B6),
                                  width: 1.5),
                            ),
                            child: Text(
                                '🌟 ${widget.bonusPoints} نقطة',
                                style: const TextStyle(
                                    color: Color(0xFF9B59B6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.cardBorderGold),
                            ),
                            child: Row(
                              children: [
                                Text(
                                    widget.category?.emoji ??
                                        '🎯',
                                    style: const TextStyle(
                                        fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  widget.category?.title ??
                                      'عامة',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.timeLimit <= 15
                                ? AppColors.wrong
                                .withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.timeLimit <= 15
                                ? '⏱️ ${widget.timeLimit}ث'
                                : 'سؤال ${widget.level == 1 ? "٢٠٠" : widget.level == 2 ? "٤٠٠" : "٦٠٠"}',
                            style: TextStyle(
                                color: widget.timeLimit <= 15
                                    ? AppColors.wrong
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── نقاط الفريقين ───────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8),
                                decoration: BoxDecoration(
                                  color:
                                  _selectedTeam == 'team1'
                                      ? AppColors.correct
                                      .withOpacity(0.2)
                                      : AppColors.surfaceColor,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                    _selectedTeam == 'team1'
                                        ? AppColors.correct
                                        : AppColors.correct
                                        .withOpacity(0.3),
                                    width:
                                    _selectedTeam == 'team1'
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    const Text('🔵',
                                        style: TextStyle(
                                            fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(widget.team1Name,
                                        style: const TextStyle(
                                            color: AppColors
                                                .textPrimary,
                                            fontSize: 11,
                                            fontWeight:
                                            FontWeight.bold),
                                        overflow:
                                        TextOverflow.ellipsis,
                                        textAlign:
                                        TextAlign.center,
                                        maxLines: 1),
                                    const SizedBox(height: 2),
                                    Text('$_team1Points نقطة',
                                        style: const TextStyle(
                                            color:
                                            AppColors.correct,
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.bold),
                                        textAlign:
                                        TextAlign.center),
                                  ],
                                ),
                              ),
                              if (_pointsController.isAnimating &&
                                  _selectedTeam == 'team1')
                                Positioned(
                                  top: -20,
                                  left: 0,
                                  right: 0,
                                  child: FadeTransition(
                                    opacity: _pointsFade,
                                    child: ScaleTransition(
                                      scale: _pointsScale,
                                      child: Text(
                                        '+$_effectivePoints',
                                        style: const TextStyle(
                                            color:
                                            AppColors.correct,
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold),
                                        textAlign:
                                        TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8),
                          child: Text('VS',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8),
                                decoration: BoxDecoration(
                                  color:
                                  _selectedTeam == 'team2'
                                      ? AppColors.correct
                                      .withOpacity(0.2)
                                      : AppColors.surfaceColor,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                    _selectedTeam == 'team2'
                                        ? AppColors.correct
                                        : AppColors.wrong
                                        .withOpacity(0.3),
                                    width:
                                    _selectedTeam == 'team2'
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    const Text('🔴',
                                        style: TextStyle(
                                            fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(widget.team2Name,
                                        style: const TextStyle(
                                            color: AppColors
                                                .textPrimary,
                                            fontSize: 11,
                                            fontWeight:
                                            FontWeight.bold),
                                        overflow:
                                        TextOverflow.ellipsis,
                                        textAlign:
                                        TextAlign.center,
                                        maxLines: 1),
                                    const SizedBox(height: 2),
                                    Text('$_team2Points نقطة',
                                        style: const TextStyle(
                                            color: AppColors.wrong,
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.bold),
                                        textAlign:
                                        TextAlign.center),
                                  ],
                                ),
                              ),
                              if (_pointsController.isAnimating &&
                                  _selectedTeam == 'team2')
                                Positioned(
                                  top: -20,
                                  left: 0,
                                  right: 0,
                                  child: FadeTransition(
                                    opacity: _pointsFade,
                                    child: ScaleTransition(
                                      scale: _pointsScale,
                                      child: Text(
                                        '+$_effectivePoints',
                                        style: const TextStyle(
                                            color:
                                            AppColors.correct,
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold),
                                        textAlign:
                                        TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── وسائل المساعدة ──────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 3,
                            runSpacing: 3,
                            children: [
                              _buildLifeline(
                                  emoji: '📞',
                                  label: 'اتصال',
                                  used: _team1CallUsed,
                                  onTap: () =>
                                      _useCall('team1')),
                              _buildLifeline(
                                  emoji: '🔍',
                                  label: 'حرف',
                                  used: _team1RevealUsed,
                                  onTap: () =>
                                      _useReveal('team1')),
                              _buildLifeline(
                                  emoji: '⏳',
                                  label: '+30ث',
                                  used: _team1ExtendUsed,
                                  onTap: () =>
                                      _useExtend('team1')),
                              _buildLifeline(
                                  emoji: '🔀',
                                  label: 'بديل',
                                  used: _team1AltUsed,
                                  onTap: () =>
                                      _useAlt('team1')),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: AppColors.cardBorder,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4),
                        ),
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 3,
                            runSpacing: 3,
                            children: [
                              _buildLifeline(
                                  emoji: '📞',
                                  label: 'اتصال',
                                  used: _team2CallUsed,
                                  onTap: () =>
                                      _useCall('team2')),
                              _buildLifeline(
                                  emoji: '🔍',
                                  label: 'حرف',
                                  used: _team2RevealUsed,
                                  onTap: () =>
                                      _useReveal('team2')),
                              _buildLifeline(
                                  emoji: '⏳',
                                  label: '+30ث',
                                  used: _team2ExtendUsed,
                                  onTap: () =>
                                      _useExtend('team2')),
                              _buildLifeline(
                                  emoji: '🔀',
                                  label: 'بديل',
                                  used: _team2AltUsed,
                                  onTap: () =>
                                      _useAlt('team2')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── شريط الوقت ──────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$_effectivePoints نقطة',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            if (_revealedHint.isNotEmpty)
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D7A5F)
                                      .withOpacity(0.15),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                      const Color(0xFF2D7A5F),
                                      width: 1),
                                ),
                                child: Text(_revealedHint,
                                    style: const TextStyle(
                                        color:
                                        Color(0xFF2D7A5F),
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.bold)),
                              ),
                            Row(
                              children: [
                                Icon(
                                  _timesUp
                                      ? Icons.timer_off_outlined
                                      : Icons.timer_outlined,
                                  color: _timesUp
                                      ? AppColors.wrong
                                      : _timerColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _timesUp
                                      ? 'انتهى الوقت!'
                                      : '$_timeLeft ث',
                                  style: TextStyle(
                                      color: _timesUp
                                          ? AppColors.wrong
                                          : _timerColor,
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _timeProgress,
                            backgroundColor:
                            AppColors.surfaceColor,
                            valueColor: AlwaysStoppedAnimation(
                                _timesUp
                                    ? AppColors.wrong
                                    : _timerColor),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── صورة/فيديو السؤال ───────────
                  if (hasQuestionVideo)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: _buildQuestionVideo(),
                    )
                  else if (hasQuestionImage)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: _buildQuestionImage(
                          question.imageUrl!),
                    ),

                  if (hasQuestionVideo || hasQuestionImage)
                    const SizedBox(height: 10),

                  // ── بطاقة السؤال ────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    child: FadeTransition(
                      opacity: _questionFade,
                      child: SlideTransition(
                        position: _questionSlide,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                              minHeight: 80),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius:
                            BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.isDoubleQuestion
                                  ? const Color(0xFF8B2635)
                                  .withOpacity(0.8)
                                  : widget.bonusPoints > 0
                                  ? const Color(0xFF9B59B6)
                                  .withOpacity(0.8)
                                  : _timesUp
                                  ? AppColors.primary
                                  .withOpacity(0.8)
                                  : AppColors
                                  .cardBorderGold,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: widget.isDoubleQuestion
                                      ? const Color(0xFF8B2635)
                                      .withOpacity(0.15)
                                      : widget.bonusPoints > 0
                                      ? const Color(0xFF9B59B6)
                                      .withOpacity(0.15)
                                      : AppColors.glowGold,
                                  blurRadius: 20),
                            ],
                          ),
                          child: Text(
                            question.question,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── الإجابة الصحيحة ─────────────
                  if (_showAnswer)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 400),
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.correct
                              .withOpacity(0.15),
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.correct,
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.correct
                                    .withOpacity(0.2),
                                blurRadius: 15),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration:
                                  const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.correct,
                                  ),
                                  child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                          'الإجابة الصحيحة',
                                          style: TextStyle(
                                              color:
                                              AppColors.correct,
                                              fontSize: 11,
                                              fontWeight:
                                              FontWeight.bold,
                                              letterSpacing: 1)),
                                      const SizedBox(height: 4),
                                      Text(
                                          question.answer ?? '—',
                                          style: const TextStyle(
                                              color: AppColors
                                                  .textPrimary,
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (hasAnswerImage) ...[
                              const SizedBox(height: 12),
                              _buildAnswerImage(
                                  question.answerImageUrl!),
                            ],
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ── أزرار الفريقين ──────────────
                  if (_selectedTeam == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 8),
                      child: Column(
                        children: [
                          Text(
                            _showAnswer
                                ? 'من أجاب صح؟'
                                : 'اضغط على الفريق الذي أجاب',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _selectWinner('team1'),
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.correct
                                          .withOpacity(0.15),
                                      borderRadius:
                                      BorderRadius.circular(
                                          14),
                                      border: Border.all(
                                          color: AppColors.correct,
                                          width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                          '🔵 ${widget.team1Name}',
                                          style: const TextStyle(
                                              color:
                                              AppColors.correct,
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight.bold),
                                          overflow: TextOverflow
                                              .ellipsis,
                                          textAlign:
                                          TextAlign.center),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    _selectWinner('none'),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceColor,
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    border: Border.all(
                                        color:
                                        AppColors.cardBorder,
                                        width: 1),
                                  ),
                                  child: const Center(
                                    child: Text('—',
                                        style: TextStyle(
                                            color:
                                            AppColors.textHint,
                                            fontSize: 18)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _selectWinner('team2'),
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.wrong
                                          .withOpacity(0.15),
                                      borderRadius:
                                      BorderRadius.circular(
                                          14),
                                      border: Border.all(
                                          color: AppColors.wrong,
                                          width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                          '🔴 ${widget.team2Name}',
                                          style: const TextStyle(
                                              color: AppColors.wrong,
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight.bold),
                                          overflow: TextOverflow
                                              .ellipsis,
                                          textAlign:
                                          TextAlign.center),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (_selectedTeam != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 16),
                      child: GestureDetector(
                        onTap: _goToResult,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryDark,
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            ),
                            borderRadius:
                            BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.glowGold,
                                  blurRadius: 15),
                            ],
                          ),
                          child: const Center(
                            child: Text('ارجع للوحة 🎯',
                                style: TextStyle(
                                  color: AppColors.background,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                )),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
              color: AppColors.cardBorderGold),
        ),
        title: const Text('مغادرة اللعبة؟',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        content: const Text('سيتم فقدان تقدمك الحالي',
            style:
            TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (!_timesUp && !_showAnswer)
                      _resumeTimer();
                  },
                  child: const Text('تابع',
                      style: TextStyle(
                          color: AppColors.primary)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, {
                      'team1': _team1Points,
                      'team2': _team2Points,
                      'team1CallUsed': _team1CallUsed,
                      'team1RevealUsed': _team1RevealUsed,
                      'team1ExtendUsed': _team1ExtendUsed,
                      'team1AltUsed': _team1AltUsed,
                      'team2CallUsed': _team2CallUsed,
                      'team2RevealUsed': _team2RevealUsed,
                      'team2ExtendUsed': _team2ExtendUsed,
                      'team2AltUsed': _team2AltUsed,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.wrong.withOpacity(0.8)),
                  child: const Text('خروج',
                      style:
                      TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}