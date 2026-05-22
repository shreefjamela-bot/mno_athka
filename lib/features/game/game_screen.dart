// ==============================
// شاشة اللعبة الرئيسية
// اسم الملف: game_screen.dart
// المكان: lib/features/game/
// ==============================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/question_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/questions_data.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;
  // الفئة — مطلوبة لشاشة النتيجة
  final CategoryModel? category;

  const GameScreen({
    super.key,
    required this.level,
    this.category,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  late List<QuestionModel> _questions;
  int _currentIndex = 0;
  int _totalPoints = 0;
  int _correctAnswers = 0; // عداد الإجابات الصحيحة
  int _timeLeft = 120;
  Timer? _timer;
  int? _selectedIndex;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.category != null
        ? QuestionsData.getByLevelAndCategory(
        widget.category!.id, widget.level)
        : QuestionsData.getByLevel(widget.level);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 120;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _timer?.cancel();
            _nextQuestion();
          }
        });
      },
    );
  }

  void _selectAnswer(int index) {
    if (_selectedIndex != null) return;
    _timer?.cancel();

    setState(() {
      _selectedIndex = index;
      _showAnswer = true;

      if (_questions[_currentIndex].isCorrect(index)) {
        _totalPoints += _questions[_currentIndex].points;
        _correctAnswers++; // زد عداد الصح
      }
    });

    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _showAnswer = false;
      });
      _startTimer();
    } else {
      _goToResult();
    }
  }

  // ==============================
  // الانتقال لشاشة النتيجة
  // ==============================
  void _goToResult() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
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
      ),
    );
  }

  Color _getAnswerColor(int index) {
    if (!_showAnswer) return AppColors.cardBackground;
    if (index == _questions[_currentIndex].correctIndex) {
      return AppColors.correct;
    }
    if (index == _selectedIndex) return AppColors.wrong;
    return AppColors.cardBackground;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'ما في أسئلة لهذا المستوى',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'النقاط: $_totalPoints',
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السؤال ${_currentIndex + 1}/${_questions.length}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontLG,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceMD,
                    vertical: AppSizes.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: _timeLeft <= 10
                        ? AppColors.wrong
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Text(
                    '⏱ $_timeLeft ثانية',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.fontLG,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceMD,
                    vertical: AppSizes.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Text(
                    '${question.points} نقطة',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceLG),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.questionCardPadding),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Text(
                question.question,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontXXL,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLG),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spaceMD),
                    child: GestureDetector(
                      onTap: () => _selectAnswer(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: AppSizes.answerButtonHeight,
                        padding: const EdgeInsets.all(AppSizes.answerButtonPadding),
                        decoration: BoxDecoration(
                          color: _getAnswerColor(index),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(
                            color: _selectedIndex == index
                                ? AppColors.primary
                                : AppColors.surfaceColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          question.options[index],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: AppSizes.fontLG,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}