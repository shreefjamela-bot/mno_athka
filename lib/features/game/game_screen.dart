// ==============================
// شاشة اللعبة — Premium Design
// اسم الملف: game_screen.dart
// ==============================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/question_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/supabase_repository.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final CategoryModel? category;

  const GameScreen({
    super.key,
    required this.level,
    this.category,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _totalPoints = 0;
  int _correctAnswers = 0;
  int _timeLeft = 120;
  Timer? _timer;
  int? _selectedIndex;
  bool _showAnswer = false;
  bool _isLoading = true;

  // أنيميشن السؤال
  late AnimationController _questionController;
  late Animation<double> _questionFade;
  late Animation<Offset> _questionSlide;

  // أنيميشن النقاط الطائرة
  late AnimationController _pointsController;
  late Animation<double> _pointsFade;
  late Animation<double> _pointsScale;

  // أنيميشن الإجابة
  late AnimationController _answerController;

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
      CurvedAnimation(parent: _questionController, curve: Curves.easeOut),
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
      CurvedAnimation(parent: _pointsController, curve: Curves.easeOut),
    );
    _pointsScale = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(parent: _pointsController, curve: Curves.easeOut),
    );

    _answerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionController.dispose();
    _pointsController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await SupabaseRepository.getQuestions(
      categoryId: widget.category?.id ?? 'general',
      level: widget.level,
    );
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
    if (_questions.isNotEmpty) {
      _questionController.forward();
      _startTimer();
    }
  }

  void _startTimer() {
    _timeLeft = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _nextQuestion();
        }
      });
    });
  }

  void _selectAnswer(int index) {
    if (_selectedIndex != null) return;
    _timer?.cancel();

    setState(() {
      _selectedIndex = index;
      _showAnswer = true;
      if (_questions[_currentIndex].isCorrect(index)) {
        _totalPoints += _questions[_currentIndex].points;
        _correctAnswers++;
        _pointsController.forward(from: 0);
      }
    });

    Future.delayed(const Duration(milliseconds: 1800), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex < _questions.length - 1) {
      _questionController.reset();
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _showAnswer = false;
      });
      _questionController.forward();
      _startTimer();
    } else {
      _goToResult();
    }
  }

  void _goToResult() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(
          totalPoints: _totalPoints,
          correctAnswers: _correctAnswers,
          totalQuestions: _questions.length,
          category: widget.category ?? CategoryModel(
            id: 'general',
            title: 'معلومات عامة',
            emoji: '🌍',
            description: '',
          ),
          level: widget.level,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  // لون الإجابة مع تأثير فاخر
  Color _getAnswerColor(int index) {
    if (!_showAnswer) return AppColors.cardBackground;
    if (index == _questions[_currentIndex].correctIndex) {
      return AppColors.correct.withOpacity(0.3);
    }
    if (index == _selectedIndex) return AppColors.wrong.withOpacity(0.3);
    return AppColors.cardBackground;
  }

  Color _getAnswerBorderColor(int index) {
    if (!_showAnswer) return AppColors.cardBorder;
    if (index == _questions[_currentIndex].correctIndex) {
      return AppColors.correct;
    }
    if (index == _selectedIndex) return AppColors.wrong;
    return AppColors.cardBorder;
  }

  // حساب نسبة الوقت
  double get _timeProgress => _timeLeft / 120;

  Color get _timerColor {
    if (_timeLeft > 60) return AppColors.correct;
    if (_timeLeft > 20) return AppColors.primary;
    return AppColors.wrong;
  }

  // حروف الخيارات
  String _getOptionLetter(int index) {
    const letters = ['أ', 'ب', 'ج', 'د'];
    return letters[index];
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
                color: AppColors.primary,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل الأسئلة...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
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
              const Text(
                'ما في أسئلة لهذا المستوى',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
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

            // ==============================
            // الخلفية — نقاط زخرفية
            // ==============================
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

            // ==============================
            // المحتوى الرئيسي
            // ==============================
            Column(
              children: [

                // ==============================
                // الهيدر
                // ==============================
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [

                      // زر الخروج
                      GestureDetector(
                        onTap: () => _showExitDialog(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.cardBorder,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // اسم الفئة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorderGold),
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.category?.emoji ?? '🎯',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.category?.title ?? 'عامة',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // النقاط
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.cardBorderGold),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.stars_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$_totalPoints',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // نقاط طائرة عند الإجابة الصحيحة
                          if (_pointsController.isAnimating)
                            Positioned(
                              top: -20,
                              right: 0,
                              child: FadeTransition(
                                opacity: _pointsFade,
                                child: ScaleTransition(
                                  scale: _pointsScale,
                                  child: Text(
                                    '+${question.points}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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

                const SizedBox(height: 20),

                // ==============================
                // شريط التقدم + المؤقت
                // ==============================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [

                      // رقم السؤال والمؤقت
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'السؤال ${_currentIndex + 1} من ${_questions.length}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: _timerColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_timeLeft ث',
                                style: TextStyle(
                                  color: _timerColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // شريط التقدم للوقت
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _timeProgress,
                          backgroundColor: AppColors.surfaceColor,
                          valueColor: AlwaysStoppedAnimation(_timerColor),
                          minHeight: 4,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // شريط تقدم الأسئلة
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questions.length,
                          backgroundColor: AppColors.surfaceColor,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary),
                          minHeight: 2,
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==============================
                // بطاقة السؤال
                // ==============================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FadeTransition(
                    opacity: _questionFade,
                    child: SlideTransition(
                      position: _questionSlide,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 140),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.cardBorderGold,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.glowGold,
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [

                            // نقاط السؤال
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${question.points} نقطة',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // نص السؤال
                            Text(
                              question.question,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ==============================
                // خيارات الإجابة
                // ==============================
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FadeTransition(
                      opacity: _questionFade,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: question.options.length,
                        itemBuilder: (context, index) {
                          final isCorrect = _showAnswer &&
                              index ==
                                  _questions[_currentIndex].correctIndex;
                          final isWrong = _showAnswer &&
                              index == _selectedIndex &&
                              !_questions[_currentIndex].isCorrect(index);

                          return GestureDetector(
                            onTap: () => _selectAnswer(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: _getAnswerColor(index),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _getAnswerBorderColor(index),
                                  width: _showAnswer &&
                                      (isCorrect || isWrong)
                                      ? 2
                                      : 1,
                                ),
                                boxShadow: isCorrect
                                    ? [
                                  BoxShadow(
                                    color: AppColors.correct
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                  )
                                ]
                                    : isWrong
                                    ? [
                                  BoxShadow(
                                    color: AppColors.wrong
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                  )
                                ]
                                    : [],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [

                                    // حرف الخيار
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _showAnswer
                                            ? (isCorrect
                                            ? AppColors.correct
                                            : isWrong
                                            ? AppColors.wrong
                                            : AppColors.surfaceColor)
                                            : AppColors.surfaceColor,
                                        border: Border.all(
                                          color: _showAnswer
                                              ? (isCorrect
                                              ? AppColors.correct
                                              : isWrong
                                              ? AppColors.wrong
                                              : AppColors.cardBorder)
                                              : AppColors.cardBorder,
                                        ),
                                      ),
                                      child: Center(
                                        child: _showAnswer && isCorrect
                                            ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                            : _showAnswer && isWrong
                                            ? const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                            : Text(
                                          _getOptionLetter(index),
                                          style: const TextStyle(
                                            color: AppColors
                                                .textSecondary,
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // نص الخيار
                                    Expanded(
                                      child: Text(
                                        question.options[index],
                                        style: TextStyle(
                                          color: _showAnswer
                                              ? (isCorrect || isWrong
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary)
                                              : AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: isCorrect || isWrong
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

              ],
            ),

          ],
        ),
      ),
    );
  }

  // ==============================
  // ديالوج الخروج
  // ==============================
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
        title: const Text(
          'مغادرة اللعبة؟',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'سيتم فقدان تقدمك الحالي',
          style: TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startTimer();
                  },
                  child: const Text(
                    'تابع',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.wrong.withOpacity(0.8),
                  ),
                  child: const Text(
                    'خروج',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}