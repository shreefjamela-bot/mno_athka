// ==============================
// شاشة تحدي الذكاء — AI Image Battle with Claude Judge
// ==============================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
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

enum _Phase { countdown, generating, capturing, judging, result }

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
  int _timeLeft = 150;
  Timer? _timer;
  String? _winner;
  int _team1Points = 0;
  int _team2Points = 0;

  Uint8List? _team1Image;
  Uint8List? _team2Image;

  bool _isJudging = false;
  String _judgeVerdict = '';
  String _judgeReason = '';

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late AnimationController _judgingController;
  late Animation<double> _judgingAnim;

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

    _judgingController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _judgingAnim = Tween<double>(begin: 0, end: 1).animate(_judgingController);

    _loadQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    _pulseController.dispose();
    _entranceController.dispose();
    _judgingController.dispose();
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

  // البرومبت المحسّن مع لقطة احترافية
  String get _enhancedPrompt =>
      '${_question!.question}\n\n🎯 أضف: "لقطة احترافية من فريق ${widget.team1Name} أو ${widget.team2Name}"';

  void _startGenerating() {
    setState(() { _phase = _Phase.generating; _timeLeft = 150; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) { _timeLeft--; }
        else { _timer?.cancel(); _phase = _Phase.capturing; }
      });
    });
  }

  Future<void> _captureImage(int team) async {
    try {
      final completer = Completer<Uint8List?>();
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..capture = 'environment';
      input.click();
      input.onChange.listen((event) {
        final file = input.files?.first;
        if (file != null) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoad.listen((e) => completer.complete(reader.result as Uint8List));
          reader.onError.listen((_) => completer.complete(null));
        } else {
          completer.complete(null);
        }
      });
      final imageBytes = await completer.future;
      if (imageBytes != null && mounted) {
        setState(() {
          if (team == 1) _team1Image = imageBytes;
          else _team2Image = imageBytes;
        });
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  // ✅ Claude يحكم بين الصورتين
  Future<void> _askClaudeToJudge() async {
    if (_team1Image == null || _team2Image == null) {
      _selectWinnerManually();
      return;
    }

    setState(() { _isJudging = true; _phase = _Phase.judging; });

    try {
      final team1Base64 = base64Encode(_team1Image!);
      final team2Base64 = base64Encode(_team2Image!);

      final response = await html.HttpRequest.request(
        'https://api.anthropic.com/v1/messages',
        method: 'POST',
        requestHeaders: {
          'Content-Type': 'application/json',
          'x-api-key': '',
          'anthropic-version': '2023-06-01',
        },
        sendData: jsonEncode({
          'model': 'claude-sonnet-4-6',
          'max_tokens': 300,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'أنت حكم في مسابقة توليد الصور. البرومبت كان: "${_question!.question}"\n\nالفريق الأول: ${widget.team1Name}\nالفريق الثاني: ${widget.team2Name}\n\nشاهد الصورتين وأجب بـ JSON فقط بهذا الشكل:\n{"winner": "team1" أو "team2" أو "tie", "reason": "سبب قصير بالعربي"}'
                },
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': 'image/jpeg',
                    'data': team1Base64,
                  }
                },
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': 'image/jpeg',
                    'data': team2Base64,
                  }
                },
              ]
            }
          ],
        }),
      );

      final data = jsonDecode(response.responseText!);
      final text = data['content'][0]['text'] as String;
      final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final verdict = jsonDecode(clean);

      final winner = verdict['winner'] as String;
      final reason = verdict['reason'] as String;

      setState(() {
        _isJudging = false;
        _judgeVerdict = winner;
        _judgeReason = reason;
        _winner = winner == 'tie' ? 'none' : winner;
        final points = _question?.points ?? 0;
        if (winner == 'team1') _team1Points += points;
        else if (winner == 'team2') _team2Points += points;
        _phase = _Phase.result;
      });

    } catch (e) {
      debugPrint('Claude judge error: $e');
      setState(() { _isJudging = false; });
      _selectWinnerManually();
    }
  }

  void _selectWinnerManually() {
    setState(() => _phase = _Phase.judging);
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
    Navigator.pop(context, {'team1': _team1Points, 'team2': _team2Points});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestion) {
      return Scaffold(backgroundColor: _bg,
          body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(color: _aiColor, strokeWidth: 2),
            const SizedBox(height: 16),
            Text('جاري تحميل التحدي...', style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 14)),
          ])));
    }

    if (_question == null) {
      return Scaffold(backgroundColor: _bg,
          body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('😕', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 16),
            const Text('ما في أسئلة', style: TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 16)),
            const SizedBox(height: 24),
            GestureDetector(onTap: _goBack, child: _goldBtn('ارجع')),
          ])));
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (_, __) => CustomPaint(
                painter: _ParticlesPainter(particles: _particles, glow: _glowAnimation.value)),
          ),
        ),
        SafeArea(child: FadeTransition(opacity: _entranceFade, child: _buildCurrentPhase())),
      ]),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case _Phase.countdown: return _buildCountdownPhase();
      case _Phase.generating: return _buildGeneratingPhase();
      case _Phase.capturing: return _buildCapturingPhase();
      case _Phase.judging: return _isJudging ? _buildJudgingLoader() : _buildManualJudging();
      case _Phase.result: return _buildResultPhase();
    }
  }

  // ===== المرحلة ١ — البرومبت =====
  Widget _buildCountdownPhase() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 16),
          Row(children: [
            GestureDetector(onTap: _goBack,
                child: Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _gold.withOpacity(0.3))),
                    child: Icon(Icons.close_rounded, color: _goldText.withOpacity(0.6), size: 18))),
            const Spacer(),
            _chip('🤖 تحدي الذكاء — ${_question!.points} نقطة', _aiColor),
            const Spacer(),
            const SizedBox(width: 38),
          ]),
          const SizedBox(height: 28),

          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _aiColor.withOpacity(0.1),
                      border: Border.all(color: _aiColor.withOpacity(0.5), width: 1.5),
                      boxShadow: [BoxShadow(color: _aiColor.withOpacity(0.3), blurRadius: 30)]),
                  child: const Center(child: Text('🤖', style: TextStyle(fontSize: 44)))),
            ),
          ),
          const SizedBox(height: 20),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: [_goldLight, _gold, _goldDark]).createShader(bounds),
            child: const Text('تحدي الذكاء الاصطناعي',
                style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),

          // البرومبت المحسّن
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (_, __) => Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _aiColor.withOpacity(0.5 * _glowAnimation.value), width: 1),
                  boxShadow: [BoxShadow(color: _aiColor.withOpacity(0.08 * _glowAnimation.value), blurRadius: 25)]),
              child: Column(children: [
                Text('البرومبت', style: TextStyle(fontFamily: 'Tajawal', color: _aiColor.withOpacity(0.6), fontSize: 11, letterSpacing: 3)),
                const SizedBox(height: 12),
                Text(_question!.question,
                    style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 17, fontWeight: FontWeight.w700, height: 1.7),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Container(height: 0.5, color: _aiColor.withOpacity(0.3)),
                const SizedBox(height: 12),
                // الحركة ١ — لقطة احترافية
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _gold.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gold.withOpacity(0.3))),
                  child: Row(children: [
                    const Text('✨', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('أضف: "لقطة احترافية سينمائية من زاوية مميزة"',
                        style: TextStyle(fontFamily: 'Tajawal', color: _gold.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // تعليمات
          Container(
            width: double.infinity, padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _gold.withOpacity(0.2))),
            child: Column(children: [
              _instructionRow('١', 'افتح ChatGPT على هاتفك 📱', _team1Color),
              const SizedBox(height: 10),
              _instructionRow('٢', 'انسخ البرومبت + أضف لقطتك الاحترافية', _gold),
              const SizedBox(height: 10),
              _instructionRow('٣', 'عندك 150 ثانية للتوليد ⏱️', _aiColor),
              const SizedBox(height: 10),
              _instructionRow('٤', 'صوّر صورتك بالكاميرا 📸', _team2Color),
              const SizedBox(height: 10),
              _instructionRow('٥', 'Claude يحكم بين الصورتين 🏆', _aiColor),
            ]),
          ),
          const SizedBox(height: 28),

          GestureDetector(
            onTap: _startGenerating,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                width: double.infinity, height: 58,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF3D2800), Color(0xFFB8890A), Color(0xFFE8C840), Color(0xFFB8890A), Color(0xFF3D2800)],
                        begin: Alignment.centerLeft, end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(29),
                    boxShadow: [BoxShadow(color: _gold.withOpacity(0.5 * _glowAnimation.value), blurRadius: 30, spreadRadius: 3)]),
                child: const Center(child: Text('ابدأ التحدي! 🚀',
                    style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF1A0E00), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3))),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ===== المرحلة ٢ — التوليد =====
  Widget _buildGeneratingPhase() {
    final progress = _timeLeft / 150.0;
    final timerColor = _timeLeft > 90 ? _team1Color : _timeLeft > 45 ? _gold : _team2Color;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 16),
        Row(children: [
          const SizedBox(width: 38), const Spacer(),
          _chip('🤖 تحدي الذكاء', _aiColor),
          const Spacer(), const SizedBox(width: 38),
        ]),
        const SizedBox(height: 32),

        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (_, __) => Stack(alignment: Alignment.center, children: [
            SizedBox(width: 180, height: 180,
                child: CircularProgressIndicator(
                    value: progress, backgroundColor: timerColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(timerColor), strokeWidth: 10)),
            Container(width: 155, height: 155,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _cardBg,
                    boxShadow: [BoxShadow(color: timerColor.withOpacity(0.2 * _glowAnimation.value), blurRadius: 30)]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('$_timeLeft',
                      style: TextStyle(fontFamily: 'Tajawal', color: timerColor, fontSize: 52, fontWeight: FontWeight.w900)),
                  Text('ثانية', style: TextStyle(fontFamily: 'Tajawal', color: timerColor.withOpacity(0.6), fontSize: 14)),
                ])),
          ]),
        ),
        const SizedBox(height: 24),

        Text(_timeLeft > 90 ? '🎨 ولّد صورتك الآن!'
            : _timeLeft > 45 ? '⚡ يلا أسرع!'
            : _timeLeft > 0 ? '🔥 آخر لحظات!'
            : '✅ انتهى الوقت!',
            style: TextStyle(fontFamily: 'Tajawal', color: timerColor, fontSize: 22, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),

        Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: _aiColor.withOpacity(0.3))),
            child: Text(_question!.question,
                style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 13, fontWeight: FontWeight.w600, height: 1.6),
                textAlign: TextAlign.center)),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(child: _teamStatus(widget.team1Name, _team1Color, '📱 يولّد...')),
          const SizedBox(width: 12),
          Expanded(child: _teamStatus(widget.team2Name, _team2Color, '📱 يولّد...')),
        ]),

        const Spacer(),

        GestureDetector(
          onTap: () { _timer?.cancel(); setState(() => _phase = _Phase.capturing); },
          child: Container(
              width: double.infinity, height: 50,
              decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(25), border: Border.all(color: _gold.withOpacity(0.3))),
              child: Center(child: Text('الكل جاهز — التقط الصور 📸',
                  style: TextStyle(fontFamily: 'Tajawal', color: _gold.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600)))),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  // ===== المرحلة ٣ — التقاط الصور =====
  Widget _buildCapturingPhase() {
    final bothCaptured = _team1Image != null && _team2Image != null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 16),
          Row(children: [
            const SizedBox(width: 38), const Spacer(),
            _chip('📸 صوّر صورتك', _gold),
            const Spacer(), const SizedBox(width: 38),
          ]),
          const SizedBox(height: 20),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: [_goldLight, _gold]).createShader(bounds),
            child: const Text('صوّر صورتك من ChatGPT',
                style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 6),
          Text('كل فريق يصوّر الصورة اللي ولّدها 📸',
              style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _captureCard(
                teamName: widget.team1Name, teamColor: _team1Color,
                image: _team1Image, onCapture: () => _captureImage(1))),
            const SizedBox(width: 12),
            Expanded(child: _captureCard(
                teamName: widget.team2Name, teamColor: _team2Color,
                image: _team2Image, onCapture: () => _captureImage(2))),
          ]),

          const SizedBox(height: 20),

          // زر إرسال لـ Claude
          if (bothCaptured) ...[
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => GestureDetector(
                onTap: _askClaudeToJudge,
                child: Container(
                  width: double.infinity, height: 58,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [_aiColor.withOpacity(0.8), _aiColor, _aiColor.withOpacity(0.8)],
                          begin: Alignment.centerLeft, end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(29),
                      boxShadow: [BoxShadow(color: _aiColor.withOpacity(0.4 * _glowAnimation.value), blurRadius: 25)]),
                  child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('🤖', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Text('Claude يحكم الآن!',
                        style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ])),
                ),
              ),
            ),
          ] else
            Container(
                width: double.infinity, padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: _gold.withOpacity(0.2))),
                child: Text(
                    _team1Image == null && _team2Image == null ? '📸 في انتظار صور الفريقين...'
                        : _team1Image == null ? '📸 في انتظار صورة ${widget.team1Name}...'
                        : '📸 في انتظار صورة ${widget.team2Name}...',
                    style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 12),
                    textAlign: TextAlign.center)),

          const SizedBox(height: 12),
          GestureDetector(
              onTap: _selectWinnerManually,
              child: Text('تخطي — احكم يدوياً',
                  style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.3), fontSize: 11))),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ===== تحميل حكم Claude =====
  Widget _buildJudgingLoader() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedBuilder(
          animation: _judgingAnim,
          builder: (_, __) => Transform.rotate(
            angle: _judgingAnim.value * 2 * pi,
            child: Container(width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [_aiColor.withOpacity(0), _aiColor])),
                child: const Center(child: Text('🤖', style: TextStyle(fontSize: 36)))),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(colors: [_goldLight, _gold]).createShader(bounds),
          child: const Text('Claude يحلل الصورتين...',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 12),
        Text('يقارن الجمال والدقة والإبداع',
            style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 13),
            textAlign: TextAlign.center),
      ]),
    );
  }

  // ===== الحكم اليدوي =====
  Widget _buildManualJudging() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 16),
          Row(children: [
            const SizedBox(width: 38), const Spacer(),
            _chip('⚖️ وقت الحكم', _gold),
            const Spacer(), const SizedBox(width: 38),
          ]),
          const SizedBox(height: 20),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: [_goldLight, _gold]).createShader(bounds),
            child: const Text('من الصورة الأجمل؟',
                style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _judgeImageCard(
                teamName: widget.team1Name, teamColor: _team1Color,
                image: _team1Image, onWin: () => _selectWinner('team1'))),
            const SizedBox(width: 12),
            Expanded(child: _judgeImageCard(
                teamName: widget.team2Name, teamColor: _team2Color,
                image: _team2Image, onWin: () => _selectWinner('team2'))),
          ]),

          const SizedBox(height: 16),
          GestureDetector(
              onTap: () => _selectWinner('none'),
              child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(25), border: Border.all(color: _gold.withOpacity(0.3))),
                  child: Center(child: Text('🤝 تعادل',
                      style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.6), fontSize: 14))))),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ===== النتيجة =====
  Widget _buildResultPhase() {
    final winnerName = _winner == 'team1' ? widget.team1Name
        : _winner == 'team2' ? widget.team2Name : 'تعادل';
    final winnerColor = _winner == 'team1' ? _team1Color
        : _winner == 'team2' ? _team2Color : _gold;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 32),

          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (_, __) => Container(width: 110, height: 110,
                decoration: BoxDecoration(shape: BoxShape.circle, color: winnerColor.withOpacity(0.1),
                    border: Border.all(color: winnerColor.withOpacity(0.5), width: 2),
                    boxShadow: [BoxShadow(color: winnerColor.withOpacity(0.3 * _glowAnimation.value), blurRadius: 40)]),
                child: const Center(child: Text('🏆', style: TextStyle(fontSize: 52)))),
          ),
          const SizedBox(height: 20),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: [_goldLight, _gold]).createShader(bounds),
            child: Text(_winner == 'none' ? '🤝 تعادل!' : '🎉 فاز $winnerName!',
                style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center),
          ),

          if (_winner != 'none') ...[
            const SizedBox(height: 10),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: winnerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: winnerColor.withOpacity(0.4))),
                child: Text('+${_question!.points} نقطة 🎯',
                    style: TextStyle(fontFamily: 'Tajawal', color: winnerColor, fontSize: 18, fontWeight: FontWeight.w700))),
          ],

          // حكم Claude
          if (_judgeReason.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _aiColor.withOpacity(0.4))),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🤖', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('حكم Claude', style: TextStyle(fontFamily: 'Tajawal', color: _aiColor, fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 10),
                Text(_judgeReason,
                    style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.8), fontSize: 13, height: 1.6),
                    textAlign: TextAlign.center),
              ]),
            ),
          ],

          // عرض الصورتين
          if (_team1Image != null || _team2Image != null) ...[
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_team1Image != null) Expanded(child: _resultImageCard(widget.team1Name, _team1Color, _team1Image!, _winner == 'team1')),
              if (_team1Image != null && _team2Image != null) const SizedBox(width: 12),
              if (_team2Image != null) Expanded(child: _resultImageCard(widget.team2Name, _team2Color, _team2Image!, _winner == 'team2')),
            ]),
          ],

          const SizedBox(height: 24),
          GestureDetector(onTap: _goBack, child: _goldBtn('ارجع للوحة 🎯')),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ===== Widgets مساعدة =====

  Widget _captureCard({
    required String teamName,
    required Color teamColor,
    required Uint8List? image,
    required VoidCallback onCapture,
  }) {
    return Container(
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: image != null ? teamColor : teamColor.withOpacity(0.3),
              width: image != null ? 1.5 : 0.8)),
      child: Column(children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: teamColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: teamColor)),
            const SizedBox(width: 6),
            Text(teamName, style: TextStyle(fontFamily: 'Tajawal', color: teamColor, fontSize: 11, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            if (image != null) ...[const SizedBox(width: 4), const Text('✅', style: TextStyle(fontSize: 10))],
          ]),
        ),
        SizedBox(height: 150,
            child: image != null
                ? ClipRRect(child: Image.memory(image, fit: BoxFit.cover, width: double.infinity))
                : Container(color: _bg, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('📸', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text('اضغط للتصوير', style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.4), fontSize: 10)),
            ]))),
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
              onTap: onCapture,
              child: Container(
                  width: double.infinity, height: 38,
                  decoration: BoxDecoration(color: teamColor.withOpacity(0.12), borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: teamColor.withOpacity(0.6), width: 0.8)),
                  child: Center(child: Text(image != null ? '🔄 أعد التصوير' : '📸 صوّر',
                      style: TextStyle(fontFamily: 'Tajawal', color: teamColor, fontSize: 11, fontWeight: FontWeight.w700))))),
        ),
      ]),
    );
  }

  Widget _judgeImageCard({
    required String teamName,
    required Color teamColor,
    required Uint8List? image,
    required VoidCallback onWin,
  }) {
    return GestureDetector(
      onTap: onWin,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (_, __) => Container(
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: teamColor.withOpacity(0.5 + 0.3 * _glowAnimation.value), width: 1.5),
              boxShadow: [BoxShadow(color: teamColor.withOpacity(0.1 * _glowAnimation.value), blurRadius: 15)]),
          child: Column(children: [
            Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: teamColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                child: Text(teamName,
                    style: TextStyle(fontFamily: 'Tajawal', color: teamColor, fontSize: 11, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
            SizedBox(height: 150,
                child: image != null
                    ? ClipRRect(child: Image.memory(image, fit: BoxFit.cover, width: double.infinity))
                    : Container(color: _bg, child: const Center(child: Text('🎨', style: TextStyle(fontSize: 36))))),
            Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: teamColor.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                child: Text('اختر فائزاً 🏆',
                    style: TextStyle(fontFamily: 'Tajawal', color: teamColor, fontSize: 12, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center)),
          ]),
        ),
      ),
    );
  }

  Widget _resultImageCard(String name, Color color, Uint8List image, bool isWinner) {
    return Container(
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isWinner ? color : color.withOpacity(0.3), width: isWinner ? 2 : 0.8)),
      child: Column(children: [
        Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
            child: Text('${isWinner ? "🏆 " : ""}$name',
                style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 10, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center)),
        ClipRRect(child: Image.memory(image, fit: BoxFit.cover, width: double.infinity, height: 130)),
      ]),
    );
  }

  Widget _teamStatus(String name, Color color, String status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.4))),
      child: Column(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(height: 6),
        Text(name, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 11, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(status, style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _instructionRow(String number, String text, Color color) {
    return Row(children: [
      Container(width: 26, height: 26,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12), border: Border.all(color: color.withOpacity(0.5))),
          child: Center(child: Text(number, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 11, fontWeight: FontWeight.w700)))),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500))),
    ]);
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.4), width: 0.8)),
      child: Text(text, style: TextStyle(fontFamily: 'Tajawal', color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _goldBtn(String text) {
    return Container(
      width: double.infinity, height: 54,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF3D2800), Color(0xFFB8890A), Color(0xFFE8C840), Color(0xFFB8890A), Color(0xFF3D2800)],
              begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 20)]),
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
      final t = (glow + i * 0.1) % 1.0;
      final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2) * 0.5 + 0.1;
      canvas.drawCircle(
          Offset(particles[i].dx * size.width, particles[i].dy * size.height),
          i % 3 == 0 ? 1.5 : 0.8,
          Paint()..color = const Color(0xFFC49830).withOpacity(opacity.clamp(0.05, 0.6)));
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.glow != glow;
}