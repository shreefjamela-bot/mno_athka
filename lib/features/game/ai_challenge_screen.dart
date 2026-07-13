// ==============================
// شاشة تحدي الذكاء — AI Image Battle
// ==============================

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/supabase_repository.dart';

const _gold = Color(0xFFC49830);
const _goldLight = Color(0xFFF0D060);
const _bg = Color(0xFF080808);
const _cardBg = Color(0xFF0E0E0E);
const _goldText = Color(0xFF5A4820);
const _team1Color = Color(0xFF2D7A5F);
const _team2Color = Color(0xFF8B2635);
const _aiColor = Color(0xFF9B59B6);

// ✅ رابط Supabase Edge Function
const _functionUrl = 'https://qfvobkacbxeyaybfcuju.supabase.co/functions/v1/generate-image';
const _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmdm9ia2FjYnhleWF5YmZjdWp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxNzIzNzQsImV4cCI6MjA2MDc0ODM3NH0.hfNZvxVU5NdJcbKMVIg3TqcqSLF9M7S6CZFK5Lv9KWA';

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

  Uint8List? _team1Image;
  Uint8List? _team2Image;
  bool _isGeneratingTeam1 = false;
  bool _isGeneratingTeam2 = false;
  String? _team1Error;
  String? _team2Error;

  String? _winner;
  int _team1Points = 0;
  int _team2Points = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _entranceFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _entranceController.forward();
    _loadQuestion();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _entranceController.dispose();
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

  // ✅ توليد الصورة عبر Supabase Edge Function باستخدام XMLHttpRequest
  Future<Uint8List?> _generateImage(String prompt) async {
    try {
      final completer = Completer<Uint8List?>();
      final xhr = html.HttpRequest();
      xhr.open('POST', _functionUrl);
      xhr.setRequestHeader('Authorization', 'Bearer $_supabaseAnonKey');
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.responseType = 'text';
      xhr.onLoad.listen((event) {
        if (xhr.status == 200) {
          try {
            final json = jsonDecode(xhr.responseText!);
            final base64String = json['image'] as String;
            completer.complete(base64Decode(base64String));
          } catch (e) {
            debugPrint('Parse error: \$e');
            completer.complete(null);
          }
        } else {
          debugPrint('HTTP Error: \${xhr.status}');
          completer.complete(null);
        }
      });
      xhr.onError.listen((event) {
        debugPrint('XHR Error');
        completer.complete(null);
      });
      xhr.send(jsonEncode({
        'prompt': '\$prompt, cinematic, photorealistic, 8k, dramatic lighting, highly detailed',
      }));
      return await completer.future.timeout(const Duration(seconds: 60));
    } catch (e) {
      debugPrint('Image generation error: \$e');
      return null;
    }
  }

  Future<void> _generateForTeam(int team) async {
    if (_question == null) return;
    final prompt = _question!.question;

    setState(() {
      if (team == 1) { _isGeneratingTeam1 = true; _team1Error = null; _team1Image = null; }
      else { _isGeneratingTeam2 = true; _team2Error = null; _team2Image = null; }
    });

    final image = await _generateImage(prompt);

    setState(() {
      if (team == 1) {
        _isGeneratingTeam1 = false;
        if (image != null) _team1Image = image;
        else _team1Error = 'فشل التوليد، حاول مرة أخرى';
      } else {
        _isGeneratingTeam2 = false;
        if (image != null) _team2Image = image;
        else _team2Error = 'فشل التوليد، حاول مرة أخرى';
      }
    });
  }

  void _selectWinner(String team) {
    if (_winner != null) return;
    final points = _question?.points ?? 0;
    setState(() {
      _winner = team;
      if (team == 'team1') _team1Points += points;
      else if (team == 'team2') _team2Points += points;
    });
  }

  void _goBack() {
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
            const Text('ما في أسئلة لهذا المستوى', style: TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 16)),
            const SizedBox(height: 24),
            GestureDetector(onTap: _goBack, child: _goldBtn('ارجع')),
          ]),
        ),
      );
    }

    final bothGenerated = _team1Image != null && _team2Image != null;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entranceFade,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ===== هيدر =====
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _goBack,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _gold.withOpacity(0.3))),
                          child: Icon(Icons.close_rounded, color: _goldText.withOpacity(0.6), size: 18),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _aiColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _aiColor.withOpacity(0.4), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🤖', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text('تحدي الذكاء — ${_question!.points} نقطة',
                                style: const TextStyle(fontFamily: 'Tajawal', color: _aiColor, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 38),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== البرومبت =====
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (_, __) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _aiColor.withOpacity(0.4 * _glowAnimation.value), width: 0.8),
                        boxShadow: [BoxShadow(color: _aiColor.withOpacity(0.05 * _glowAnimation.value), blurRadius: 20)],
                      ),
                      child: Column(
                        children: [
                          Text('البرومبت', style: TextStyle(fontFamily: 'Tajawal', color: _aiColor.withOpacity(0.7), fontSize: 11, letterSpacing: 2)),
                          const SizedBox(height: 10),
                          Text(_question!.question,
                            style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 17, fontWeight: FontWeight.w700, height: 1.6),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== منطقة توليد الصور =====
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _teamImageCard(
                        teamName: widget.team1Name,
                        teamColor: _team1Color,
                        image: _team1Image,
                        isGenerating: _isGeneratingTeam1,
                        error: _team1Error,
                        isWinner: _winner == 'team1',
                        onGenerate: () => _generateForTeam(1),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _teamImageCard(
                        teamName: widget.team2Name,
                        teamColor: _team2Color,
                        image: _team2Image,
                        isGenerating: _isGeneratingTeam2,
                        error: _team2Error,
                        isWinner: _winner == 'team2',
                        onGenerate: () => _generateForTeam(2),
                      )),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ===== الحكم =====
                  if (bothGenerated && _winner == null) ...[
                    Text('من الصورة الأجمل؟',
                        style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.6), fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _winnerBtn(widget.team1Name, _team1Color, () => _selectWinner('team1'))),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _selectWinner('none'),
                          child: Container(
                            width: 48, height: 52,
                            decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _gold.withOpacity(0.2))),
                            child: Center(child: Text('—', style: TextStyle(color: _goldText.withOpacity(0.4), fontSize: 18))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _winnerBtn(widget.team2Name, _team2Color, () => _selectWinner('team2'))),
                      ],
                    ),
                  ],

                  // ===== النتيجة =====
                  if (_winner != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _gold.withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          Text(
                            _winner == 'team1' ? '${widget.team1Name} فاز!'
                                : _winner == 'team2' ? '${widget.team2Name} فاز!'
                                : 'تعادل!',
                            style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text('+${_question!.points} نقطة',
                              style: const TextStyle(fontFamily: 'Tajawal', color: _gold, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(onTap: _goBack, child: _goldBtn('ارجع للوحة 🎯')),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _teamImageCard({
    required String teamName,
    required Color teamColor,
    required Uint8List? image,
    required bool isGenerating,
    required String? error,
    required bool isWinner,
    required VoidCallback onGenerate,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner ? teamColor : teamColor.withOpacity(0.3),
          width: isWinner ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: teamColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: teamColor)),
                const SizedBox(width: 6),
                Text(teamName,
                    style: TextStyle(fontFamily: 'Tajawal', color: teamColor, fontSize: 11, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
                if (isWinner) ...[const SizedBox(width: 4), const Text('🏆', style: TextStyle(fontSize: 10))],
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: isGenerating
                  ? _loadingWidget(teamColor)
                  : image != null
                  ? Image.memory(image, fit: BoxFit.cover, width: double.infinity)
                  : _placeholderWidget(teamColor, error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: isGenerating ? null : onGenerate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 38,
                decoration: BoxDecoration(
                  color: isGenerating ? _cardBg : teamColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: isGenerating ? teamColor.withOpacity(0.2) : teamColor.withOpacity(0.6), width: 0.8),
                ),
                child: Center(
                  child: Text(
                    isGenerating ? 'يولّد...' : image != null ? 'أعد التوليد 🔄' : 'ولّد الصورة ✨',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: isGenerating ? teamColor.withOpacity(0.3) : teamColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingWidget(Color color) {
    return Container(
      color: _bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: color, strokeWidth: 2)),
          const SizedBox(height: 12),
          Text('يولّد الصورة...', style: TextStyle(fontFamily: 'Tajawal', color: color.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 4),
          Text('قد يستغرق 15-30 ثانية', style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.4), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _placeholderWidget(Color color, String? error) {
    return Container(
      color: _bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error != null ? '⚠️' : '🎨', style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            error ?? 'اضغط لتوليد الصورة',
            style: TextStyle(fontFamily: 'Tajawal', color: error != null ? _team2Color : _goldText.withOpacity(0.5), fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _winnerBtn(String name, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
              overflow: TextOverflow.ellipsis),
        ),
      ),
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
      child: Center(
        child: Text(text, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF1A0E00), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
    );
  }
}