// ==============================
// شاشة تحدي الذكاء — AI Image Battle
// ==============================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/supabase_repository.dart';

const _gold = Color(0xFFC49830);
const _goldLight = Color(0xFFF0D060);
const _goldDark = Color(0xFF6B4A10);
const _bg = Color(0xFF080808);
const _cardBg = Color(0xFF0E0E0E);
const _goldText = Color(0xFF5A4820);
const _team1Color = Color(0xFF2D7A5F);
const _team2Color = Color(0xFF8B2635);
const _aiColor = Color(0xFF9B59B6);

enum _Phase { countdown, generating, judging, result }

class AiChallengeScreen extends StatefulWidget {
  final int level;
  final CategoryModel category;
  final String team1Name;
  final String team2Name;

  const AiChallengeScreen({
    super.key,
    required this.level,
    required this.category,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  State<AiChallengeScreen> createState() => _AiChallengeScreenState();
}

class _AiChallengeScreenState extends State<AiChallengeScreen>
    with TickerProviderStateMixin {

  QuestionModel? _question;
  bool _isLoadingQuestion = true;
  _Phase _phase = _Phase.countdown;
  int _timeLeft = 120;
  Timer? _timer;
  String? _winner;
  int _team1Points = 0;
  int _team2Points = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late AnimationController _timerController;

  // نجوم خلفية
  final _random = Random(42);
  late final List<Offset> _particles;

  @override
  void initState() {
    super.initState();

    _particles = List.generate(30, (_) => Offset(_random.nextDouble(), _random.nextDouble()));

    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _entranceFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _entranceController.forward();

    _timerController = AnimationController(vsync: this, duration: const Duration(seconds: 120));

    _loadQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    _pulseController.dispose();
    _entranceController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestion() async {
    final questions = await SupabaseRepository.getQuestions(
      categoryId: widget.category.id,
      level: widget.level,
    );
    if (questions.isNotEmpty) {
      final picked = (questions..shuffle()).first;
      setState(() { _question = picked; _isLoadingQuestion = false; });
    } else {
      setState(() => _isLoadingQuestion = false);
    }
  }

  void _startGenerating() {
    setState(() { _phase = _Phase.generating; _timeLeft = 120; });
    _timerController.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _phase = _Phase.judging;
        }
      });
    });
  }

  void _selectWinner(String team) {
    if (_winner != null) return;
    final points = _question?.points ?? 0;
    setState(() {
      _winner = team;
      _phase = _Phase.result;
      if (team == 'team1') _team1Points += points;
      else if (team == 'team2') _team2Points += points;
    });
  }

  void _goBack() {
    _timer?.cancel();
    Navigator.pop(context, {
      'team1': _team1Points,
      'team2': _team2Points,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestion) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(color: _aiColor, strokeWidth: 2),
            const SizedBox(height: 16),
            Text('جاري تحميل التحدي...', style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 14)),
          ]),
        ),
      );
    }

    if (_question == null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('😕', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 16),
            const Text('ما في أسئلة', style: TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 16)),
            const SizedBox(height: 24),
            GestureDetector(onTap: _goBack, child: _goldBtn('ارجع')),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // جسيمات خلفية
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => CustomPaint(
                painter: _ParticlesPainter(particles: _particles, glow: _glowAnimation.value),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _entranceFade,
              child: _buildCurrentPhase(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case _Phase.countdown:
        return _buildCountdownPhase();
      case _Phase.generating:
        return _buildGeneratingPhase();
      case _Phase.judging:
        return _buildJudgingPhase();
      case _Phase.result:
        return _buildResultPhase();
    }
  }

  // ===== المرحلة ١ — عرض البرومبت =====
  Widget _buildCountdownPhase() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // هيدر
            Row(
              children: [
                GestureDetector(onTap: _goBack,
                    child: Container(width: 38, height: 38,
                        decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _gold.withOpacity(0.3))),
                        child: Icon(Icons.close_rounded, color: _goldText.withOpacity(0.6), size: 18))),
                const Spacer(),
                _chip('🤖 تحدي الذكاء — ${_question!.points} نقطة', _aiColor),
                const Spacer(),
                const SizedBox(width: 38),
              ],
            ),

            const SizedBox(height: 32),

            // أيقونة AI
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _aiColor.withOpacity(0.1),
                    border: Border.all(color: _aiColor.withOpacity(0.5), width: 1.5),
                    boxShadow: [BoxShadow(color: _aiColor.withOpacity(0.3), blurRadius: 30)],
                  ),
                  child: const Center(child: Text('🤖', style: TextStyle(fontSize: 44))),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: [_goldLight, _gold, _goldDark]).createShader(bounds),
              child: const Text('تحدي الذكاء الاصطناعي',
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center),
            ),

            const SizedBox(height: 8),
            Text('ولّد الصورة الأجمل باستخدام ChatGPT',
                style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.6), fontSize: 13, letterSpacing: 1),
                textAlign: TextAlign.center),

            const SizedBox(height: 28),

            // البرومبت
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _aiColor.withOpacity(0.5 * _glowAnimation.value), width: 1),
                  boxShadow: [BoxShadow(color: _aiColor.withOpacity(0.08 * _glowAnimation.value), blurRadius: 25)],
                ),
                child: Column(
                  children: [
                    Text('البرومبت', style: TextStyle(fontFamily: 'Tajawal', color: _aiColor.withOpacity(0.6), fontSize: 11, letterSpacing: 3)),
                    const SizedBox(height: 12),
                    Text(_question!.question,
                        style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 18, fontWeight: FontWeight.w700, height: 1.7),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // تعليمات
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _instructionRow('١', 'افتح ChatGPT على هاتفك 📱', _team1Color),
                  const SizedBox(height: 10),
                  _instructionRow('٢', 'انسخ البرومبت وأرسله لـ ChatGPT', _gold),
                  const SizedBox(height: 10),
                  _instructionRow('٣', 'عندك 120 ثانية لتوليد أجمل صورة ⏱️', _aiColor),
                  const SizedBox(height: 10),
                  _instructionRow('٤', 'اعرض صورتك للمقدم والجمهور 🏆', _team2Color),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // زر البدء
            GestureDetector(
              onTap: _startGenerating,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (_, __) => Container(
                  width: double.infinity, height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D2800), Color(0xFFB8890A), Color(0xFFE8C840), Color(0xFFB8890A), Color(0xFF3D2800)],
                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(29),
                    boxShadow: [BoxShadow(color: _gold.withOpacity(0.5 * _glowAnimation.value), blurRadius: 30, spreadRadius: 3)],
                  ),
                  child: const Center(
                    child: Text('ابدأ التحدي! 🚀',
                        style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF1A0E00), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== المرحلة ٢ — التوليد =====
  Widget _buildGeneratingPhase() {
    final progress = _timeLeft / 120.0;
    final timerColor = _timeLeft > 60 ? _team1Color : _timeLeft > 30 ? _gold : _team2Color;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),

          Row(
            children: [
              const SizedBox(width: 38),
              const Spacer(),
              _chip('🤖 تحدي الذكاء', _aiColor),
              const Spacer(),
              const SizedBox(width: 38),
            ],
          ),

          const SizedBox(height: 32),

          // مؤقت دائري كبير
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180, height: 180,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: timerColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(timerColor),
                    strokeWidth: 8,
                  ),
                ),
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cardBg,
                    boxShadow: [BoxShadow(color: timerColor.withOpacity(0.2 * _glowAnimation.value), blurRadius: 30)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$_timeLeft',
                          style: TextStyle(fontFamily: 'Tajawal', color: timerColor, fontSize: 52, fontWeight: FontWeight.w900)),
                      Text('ثانية',
                          style: TextStyle(fontFamily: 'Tajawal', color: timerColor.withOpacity(0.6), fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(_timeLeft > 60 ? 'ولّد صورتك الآن! 🎨'
              : _timeLeft > 30 ? 'يلا أسرع! ⚡'
              : _timeLeft > 0 ? 'آخر لحظات! 🔥'
              : 'انتهى الوقت!',
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: timerColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // البرومبت
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _aiColor.withOpacity(0.3)),
            ),
            child: Text(_question!.question,
                style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 15, fontWeight: FontWeight.w600, height: 1.6),
                textAlign: TextAlign.center),
          ),

          const SizedBox(height: 24),

          // الفريقان
          Row(
            children: [
              Expanded(child: _teamStatus(widget.team1Name, _team1Color, '📱 يولّد...')),
              const SizedBox(width: 12),
              Expanded(child: _teamStatus(widget.team2Name, _team2Color, '📱 يولّد...')),
            ],
          ),

          const Spacer(),

          // زر إنهاء مبكر
          GestureDetector(
            onTap: () { _timer?.cancel(); setState(() { _phase = _Phase.judging; }); },
            child: Container(
              width: double.infinity, height: 50,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              child: Center(
                child: Text('الكل جاهز — ابدأ الحكم ✓',
                    style: TextStyle(fontFamily: 'Tajawal', color: _gold.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ===== المرحلة ٣ — الحكم =====
  Widget _buildJudgingPhase() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            Row(
              children: [
                const SizedBox(width: 38),
                const Spacer(),
                _chip('🏆 وقت الحكم', _gold),
                const Spacer(),
                const SizedBox(width: 38),
              ],
            ),

            const SizedBox(height: 32),

            // أيقونة الحكم
            const Text('⚖️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),

            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: [_goldLight, _gold]).createShader(bounds),
              child: const Text('من الصورة الأجمل؟',
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center),
            ),

            const SizedBox(height: 8),
            Text('كل فريق يعرض صورته — المقدم يحكم',
                style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.6), fontSize: 13),
                textAlign: TextAlign.center),

            const SizedBox(height: 32),

            // بطاقتا الفريقين
            Row(
              children: [
                Expanded(child: _judgeTeamCard(widget.team1Name, _team1Color, 'team1')),
                const SizedBox(width: 16),
                Expanded(child: _judgeTeamCard(widget.team2Name, _team2Color, 'team2')),
              ],
            ),

            const SizedBox(height: 20),

            // زر تعادل
            GestureDetector(
              onTap: () => _selectWinner('none'),
              child: Container(
                width: double.infinity, height: 50,
                decoration: BoxDecoration(
                  color: _cardBg, borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: _gold.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text('🤝 تعادل — الصورتان متساويتان',
                      style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.6), fontSize: 13)),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== المرحلة ٤ — النتيجة =====
  Widget _buildResultPhase() {
    final winnerName = _winner == 'team1' ? widget.team1Name
        : _winner == 'team2' ? widget.team2Name : 'تعادل';
    final winnerColor = _winner == 'team1' ? _team1Color
        : _winner == 'team2' ? _team2Color : _gold;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (_, __) => Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: winnerColor.withOpacity(0.1),
                border: Border.all(color: winnerColor.withOpacity(0.5), width: 2),
                boxShadow: [BoxShadow(color: winnerColor.withOpacity(0.3 * _glowAnimation.value), blurRadius: 40)],
              ),
              child: const Center(child: Text('🏆', style: TextStyle(fontSize: 52))),
            ),
          ),

          const SizedBox(height: 24),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: [_goldLight, _gold]).createShader(bounds),
            child: Text(_winner == 'none' ? '🤝 تعادل!' : '🎉 فاز ${winnerName}!',
                style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center),
          ),

          const SizedBox(height: 12),

          if (_winner != 'none')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: winnerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: winnerColor.withOpacity(0.4)),
              ),
              child: Text('+${_question!.points} نقطة 🎯',
                  style: TextStyle(fontFamily: 'Tajawal', color: winnerColor, fontSize: 18, fontWeight: FontWeight.w700)),
            ),

          const SizedBox(height: 40),

          GestureDetector(onTap: _goBack, child: _goldBtn('ارجع للوحة 🎯')),
        ],
      ),
    );
  }

  // ===== Widgets مساعدة =====

  Widget _judgeTeamCard(String name, Color color, String teamId) {
    return GestureDetector(
      onTap: () => _selectWinner(teamId),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (_, __) => Container(
          height: 140,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5 + 0.3 * _glowAnimation.value), width: 1.5),
            boxShadow: [BoxShadow(color: color.withOpacity(0.15 * _glowAnimation.value), blurRadius: 20)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(height: 10),
              Text(name, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 16, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text('فاز! 🏆', style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamStatus(String name, Color color, String status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(height: 6),
          Text(name, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 11, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _instructionRow(String number, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.5))),
          child: Center(child: Text(number, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 11, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(text, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _goldBtn(String text) {
    return Container(
      width: double.infinity, height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D2800), Color(0xFFB8890A), Color(0xFFE8C840), Color(0xFFB8890A), Color(0xFF3D2800)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 20)],
      ),
      child: Center(child: Text(text,
          style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF1A0E00), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2))),
    );
  }
}

// ===== رسام الجسيمات =====
class _ParticlesPainter extends CustomPainter {
  final List<Offset> particles;
  final double glow;

  _ParticlesPainter({required this.particles, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final opacity = (sin(glow * 3.14 * 2 + i) * 0.3 + 0.4).clamp(0.1, 0.7);
      canvas.drawCircle(
        Offset(particles[i].dx * size.width, particles[i].dy * size.height),
        i % 3 == 0 ? 1.5 : 0.8,
        Paint()..color = const Color(0xFFC49830).withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.glow != glow;
}

double sin(double x) => (x - x.floor()) < 0.5 ? 2 * (x - x.floor()) : 2 * (1 - (x - x.floor()));