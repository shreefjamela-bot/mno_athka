// ==============================
// شاشة اللعبة — Open Question System
// اسم الملف: game_screen.dart
// ==============================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/question_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/supabase_repository.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final CategoryModel? category;
  final String team1Name;
  final String team2Name;

  const GameScreen({
    super.key,
    required this.level,
    this.category,
    this.team1Name = 'الفريق الأول',
    this.team2Name = 'الفريق الثاني',
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _team1Points = 0;
  int _team2Points = 0;
  int _timeLeft = 120;
  Timer? _timer;
  bool _isLoading = true;
  bool _timesUp = false;
  bool _showAnswer = false;
  String? _selectedTeam;

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

  Future<void> _loadQuestions() async {
    final allQuestions = await SupabaseRepository.getQuestions(
      categoryId: widget.category?.id ?? 'general',
      level: widget.level,
    );

    setState(() {
      if (allQuestions.isEmpty) {
        _questions = [];
      } else {
        final random = Random();
        final picked = allQuestions[random.nextInt(allQuestions.length)];
        _questions = [picked];
      }
      _isLoading = false;
    });

    if (_questions.isNotEmpty) {
      _questionController.forward();
      _startTimer();
    }
  }

  void _startTimer() {
    _timeLeft = 120;
    _timesUp = false;
    _showAnswer = false;
    _selectedTeam = null;
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

  // ← الدالة المعدلة
  Future<void> _playApplause() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/applause.wav'));
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  void _selectWinner(String team) {
    if (_selectedTeam != null) return;
    _timer?.cancel();

    setState(() {
      _selectedTeam = team;
      _showAnswer = true;
      _timesUp = true;
      final points = _questions[_currentIndex].points;

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
    });
  }

  double get _timeProgress => _timeLeft / 120;

  Color get _timerColor {
    if (_timeLeft > 60) return AppColors.correct;
    if (_timeLeft > 20) return AppColors.primary;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
              const SizedBox(height: 16),
              const Text('جاري تحميل الأسئلة...',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
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
              const Text('😕', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text('ما في أسئلة لهذا المستوى',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, {
                  'team1': _team1Points,
                  'team2': _team2Points,
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

            Column(
              children: [

                // الهيدر
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _showExitDialog,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.cardBorder),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: AppColors.textSecondary,
                              size: 18),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.cardBorderGold),
                        ),
                        child: Row(
                          children: [
                            Text(widget.category?.emoji ?? '🎯',
                                style:
                                const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              widget.category?.title ?? 'عامة',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'سؤال ${widget.level == 1 ? "٢٠٠" : widget.level == 2 ? "٤٠٠" : "٦٠٠"}',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // نقاط الفريقين
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [

                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _selectedTeam == 'team1'
                                    ? AppColors.correct
                                    .withOpacity(0.2)
                                    : AppColors.surfaceColor,
                                borderRadius:
                                BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedTeam == 'team1'
                                      ? AppColors.correct
                                      : AppColors.correct
                                      .withOpacity(0.3),
                                  width: _selectedTeam == 'team1'
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
                                      style:
                                      TextStyle(fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(widget.team1Name,
                                      style: const TextStyle(
                                          color:
                                          AppColors.textPrimary,
                                          fontSize: 11,
                                          fontWeight:
                                          FontWeight.bold),
                                      overflow:
                                      TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 1),
                                  const SizedBox(height: 2),
                                  Text('$_team1Points نقطة',
                                      style: const TextStyle(
                                          color: AppColors.correct,
                                          fontSize: 13,
                                          fontWeight:
                                          FontWeight.bold),
                                      textAlign: TextAlign.center),
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
                                        '+${question.points}',
                                        style: const TextStyle(
                                            color: AppColors.correct,
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold),
                                        textAlign:
                                        TextAlign.center),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8),
                        child: const Text('VS',
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _selectedTeam == 'team2'
                                    ? AppColors.correct
                                    .withOpacity(0.2)
                                    : AppColors.surfaceColor,
                                borderRadius:
                                BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedTeam == 'team2'
                                      ? AppColors.correct
                                      : AppColors.wrong
                                      .withOpacity(0.3),
                                  width: _selectedTeam == 'team2'
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
                                      style:
                                      TextStyle(fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(widget.team2Name,
                                      style: const TextStyle(
                                          color:
                                          AppColors.textPrimary,
                                          fontSize: 11,
                                          fontWeight:
                                          FontWeight.bold),
                                      overflow:
                                      TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 1),
                                  const SizedBox(height: 2),
                                  Text('$_team2Points نقطة',
                                      style: const TextStyle(
                                          color: AppColors.wrong,
                                          fontSize: 13,
                                          fontWeight:
                                          FontWeight.bold),
                                      textAlign: TextAlign.center),
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
                                        '+${question.points}',
                                        style: const TextStyle(
                                            color: AppColors.correct,
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold),
                                        textAlign:
                                        TextAlign.center),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // شريط الوقت
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${question.points} نقطة',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
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
                                    fontWeight: FontWeight.bold),
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
                          backgroundColor: AppColors.surfaceColor,
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

                const SizedBox(height: 14),

                // بطاقة السؤال
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FadeTransition(
                    opacity: _questionFade,
                    child: SlideTransition(
                      position: _questionSlide,
                      child: Container(
                        width: double.infinity,
                        constraints:
                        const BoxConstraints(minHeight: 130),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _timesUp
                                ? AppColors.primary.withOpacity(0.8)
                                : AppColors.cardBorderGold,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.glowGold,
                                blurRadius: 20),
                          ],
                        ),
                        child: Text(
                          question.question,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // الإجابة الصحيحة
                if (_showAnswer)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.correct.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.correct, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color:
                              AppColors.correct.withOpacity(0.2),
                              blurRadius: 15),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.correct,
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text('الإجابة الصحيحة',
                                    style: TextStyle(
                                        color: AppColors.correct,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text(question.answer ?? '—',
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const Spacer(),

                // أزرار الفريقين
                if (_selectedTeam == null)
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      children: [
                        Text(
                          _showAnswer
                              ? 'من أجاب صح؟'
                              : 'اضغط على الفريق الذي أجاب',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 0.5),
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
                                    BorderRadius.circular(14),
                                    border: Border.all(
                                        color: AppColors.correct,
                                        width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                        '🔵 ${widget.team1Name}',
                                        style: const TextStyle(
                                            color: AppColors.correct,
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.bold),
                                        overflow:
                                        TextOverflow.ellipsis,
                                        textAlign:
                                        TextAlign.center),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _selectWinner('none'),
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor,
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.cardBorder,
                                      width: 1),
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
                                    BorderRadius.circular(14),
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
                                        overflow:
                                        TextOverflow.ellipsis,
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

                // زر الرجوع للوحة
                if (_selectedTeam != null)
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.glowGold,
                                blurRadius: 15),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'ارجع للوحة 🎯',
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

              ],
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
          side: const BorderSide(color: AppColors.cardBorderGold),
        ),
        title: const Text('مغادرة اللعبة؟',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        content: const Text('سيتم فقدان تقدمك الحالي',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (!_timesUp && !_showAnswer) _startTimer();
                  },
                  child: const Text('تابع',
                      style:
                      TextStyle(color: AppColors.primary)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, {
                      'team1': _team1Points,
                      'team2': _team2Points,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.wrong.withOpacity(0.8)),
                  child: const Text('خروج',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}