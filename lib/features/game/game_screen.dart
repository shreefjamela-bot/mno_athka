// ==============================
// شاشة اللعبة الرئيسية
// اسم الملف: game_screen.dart
// المكان: lib/features/game/
//
// هنا يصير اللعب الفعلي
// سؤال + خيارات + مؤقت + نقاط
// ==============================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/questions_data.dart';

class GameScreen extends StatefulWidget {
  // المستوى اللي اختاره اللاعب
  final int level;

  const GameScreen({
    super.key,
    required this.level,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

// ==============================
// _GameScreenState
// StatefulWidget = يتغير حسب اللعب
// ==============================
class _GameScreenState extends State<GameScreen> {

  // ==============================
  // المتغيرات — حالة اللعبة
  // ==============================

  // قائمة الأسئلة حسب المستوى
  late List<QuestionModel> _questions;

  // رقم السؤال الحالي — يبدأ من ٠
  int _currentIndex = 0;

  // النقاط الكلية
  int _totalPoints = 0;

  // الوقت المتبقي بالثواني
  int _timeLeft = 120;

  // المؤقت
  Timer? _timer;

  // رقم الإجابة اللي اختارها اللاعب
  // null = ما اختار بعد
  int? _selectedIndex;

  // هل ظهرت الإجابة الصحيحة
  bool _showAnswer = false;

  // ==============================
  // initState — يشتغل أول ما تفتح الشاشة
  // ==============================
  @override
  void initState() {
    super.initState();
    // جيب الأسئلة حسب المستوى
    _questions = QuestionsData.getByLevel(widget.level);
    // ابدأ المؤقت
    _startTimer();
  }

  // ==============================
  // dispose — يشتغل لما تقفل الشاشة
  // مهم عشان ما يحدث memory leak
  // ==============================
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ==============================
  // دالة المؤقت
  // ==============================
  void _startTimer() {
    // الوقت حسب المستوى
    _timeLeft = 120;

    // Timer.periodic = يشتغل كل ثانية
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        setState(() {
          if (_timeLeft > 0) {
            // نقص ثانية
            _timeLeft--;
          } else {
            // انتهى الوقت — انتقل للسؤال الجاي
            _timer?.cancel();
            _nextQuestion();
          }
        });
      },
    );
  }

  // ==============================
  // دالة اختيار الإجابة
  // ==============================
  void _selectAnswer(int index) {
    // إذا اختار قبل — ما يغير
    if (_selectedIndex != null) return;

    // وقف المؤقت
    _timer?.cancel();

    setState(() {
      _selectedIndex = index;
      _showAnswer = true;

      // إذا صح — زد النقاط
      if (_questions[_currentIndex].isCorrect(index)) {
        _totalPoints += _questions[_currentIndex].points;
      }
    });

    // بعد ثانيتين انتقل للسؤال الجاي
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  // ==============================
  // دالة الانتقال للسؤال الجاي
  // ==============================
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _showAnswer = false;
      });
      // ابدأ المؤقت من جديد
      _startTimer();
    } else {
      // خلصت الأسئلة — روح لشاشة النتيجة
      _showResult();
    }
  }

  // ==============================
  // دالة عرض النتيجة النهائية
  // ==============================
  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: const Text(
          '🏆 انتهت اللعبة!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: AppColors.gold,
              size: 60,
            ),
            const SizedBox(height: AppSizes.spaceMD),
            Text(
              'نقاطك: $_totalPoints',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // أغلق الديالوج وارجع للرئيسية
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('ارجع للرئيسية'),
          ),
        ],
      ),
    );
  }

  // ==============================
  // لون زر الإجابة حسب الحالة
  // ==============================
  Color _getAnswerColor(int index) {
    // ما اختار بعد — اللون الافتراضي
    if (!_showAnswer) return AppColors.cardBackground;

    // الإجابة الصحيحة — أخضر
    if (index == _questions[_currentIndex].correctIndex) {
      return AppColors.correct;
    }

    // الإجابة اللي اختارها — أحمر إذا غلط
    if (index == _selectedIndex) return AppColors.wrong;

    // باقي الخيارات — افتراضي
    return AppColors.cardBackground;
  }

  // ==============================
  // build — يبني الشاشة
  // ==============================
  @override
  Widget build(BuildContext context) {
    // إذا ما في أسئلة
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

    // السؤال الحالي
    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,

      // ==============================
      // الشريط العلوي
      // ==============================
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

            // ==============================
            // المؤقت وعداد الأسئلة
            // ==============================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // عداد الأسئلة
                Text(
                  'السؤال ${_currentIndex + 1}/${_questions.length}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontLG,
                  ),
                ),
                // المؤقت
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
                // النقاط للسؤال
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

            // ==============================
            // بطاقة السؤال
            // ==============================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.questionCardPadding),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1,
                ),
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

            // ==============================
            // خيارات الإجابة
            // ==============================
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSizes.spaceMD),
                    child: GestureDetector(
                      onTap: () => _selectAnswer(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: AppSizes.answerButtonHeight,
                        padding: const EdgeInsets.all(
                            AppSizes.answerButtonPadding),
                        decoration: BoxDecoration(
                          // اللون يتغير حسب الإجابة
                          color: _getAnswerColor(index),
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusMD),
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