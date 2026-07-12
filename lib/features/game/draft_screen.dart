// ==============================
// شاشة Draft الفئات — Luxury Theme
// اسم الملف: draft_screen.dart
// ==============================

import 'wheel_screen.dart';
import '../../data/repositories/supabase_repository.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/categories_data.dart';
import '../../data/models/category_model.dart';
import 'match_board_screen.dart';

const Map<String, String> _categoryImages = {
  'الحرب العالمية': 'assets/images/categories/harb.png',
  'كرة قدم عالمية': 'assets/images/categories/koora.png',
  'الأكلات العالمية': 'assets/images/categories/aklat.png',
  'كأس العالم': 'assets/images/categories/kas.png',
  'رياضة': 'assets/images/categories/riyada.png',
  'سبيستون': 'assets/images/categories/siston.png',
  'السوشل ميديا': 'assets/images/categories/social.png',
  'شخصيات ورموز': 'assets/images/categories/characters.png',
  'مسلسلات': 'assets/images/categories/mosalsal.png',
  'أفلام': 'assets/images/categories/aflam.png',
  'خرايط': 'assets/images/categories/maps.png',
  'من قال هذه المقولة': 'assets/images/categories/maqola.png',
  'قصص الأنبياء': 'assets/images/categories/anbiya.png',
  'منتجات': 'assets/images/categories/products.png',
  'طبيعت': 'assets/images/categories/tabea.png',
  'السعودية': 'assets/images/categories/saudi.png',
  'شغل مخك': 'assets/images/categories/shoghl.png',
  'أمثال وألغاز': 'assets/images/categories/amthal.png',
  'الكويت': 'assets/images/categories/kuwait.png',
  'كتب وروايات': 'assets/images/categories/kutub.png',
  'خمن الشخصية من صورة/فيديو AI': 'assets/images/categories/ai.png',
  'معلومات عامة': 'assets/images/categories/general.png',
  'محمد الفاتح': 'assets/images/categories/fatih.png',
  'الصحابة': 'assets/images/categories/sahaba.png',
  'الخليج العربي': 'assets/images/categories/gulf.png',
  'اكتشف الخط': 'assets/images/categories/khat.png',
  'اختراعات': 'assets/images/categories/ikhtiraat.png',
  'مسلسلات تاريخية': 'assets/images/categories/tarikh.png',
  'فن خليجي': 'assets/images/categories/fan.png',
  'بنات وبس': 'assets/images/categories/banat.png',
  'انمي': 'assets/images/categories/japan.png',
  'عالم الحيوان': 'assets/images/categories/animals.png',
  'اكمل الجملة': 'assets/images/categories/jumla.png',
  'أعلام وشعارات': 'assets/images/categories/flags.png',
  'لغة وأدب وشعر': 'assets/images/categories/luga.png',
  'معالم دول': 'assets/images/categories/maalim.png',
  'الكلاسيكو': 'assets/images/categories/classico.png',
  'حضارات ودول': 'assets/images/categories/hisabat.png',
  'سيارات': 'assets/images/categories/cars.png',
  'عجائب العالم': 'assets/images/categories/ajayeb.png',
  'أهل البيت': 'assets/images/categories/ahlbayt.png',
  'طربيات': 'assets/images/categories/tarb.png',
};

// ألوان الثيم الفاخر
const _gold = Color(0xFFC49830);
const _goldLight = Color(0xFFF0D060);
const _bg = Color(0xFF080808);
const _cardBg = Color(0xFF0E0E0E);
const _goldText = Color(0xFF5A4820);

class DraftScreen extends StatefulWidget {
  const DraftScreen({super.key});

  @override
  State<DraftScreen> createState() => _DraftScreenState();
}

enum DraftPhase {
  enterNames,
  team1Pick,
  team2Ban,
  team2Pick,
  team1Ban,
  summary,
}

class _DraftScreenState extends State<DraftScreen> with SingleTickerProviderStateMixin {
  DraftPhase _phase = DraftPhase.enterNames;

  final _team1Controller = TextEditingController(text: 'الفريق الأول');
  final _team2Controller = TextEditingController(text: 'الفريق الثاني');

  String team1Name = '';
  String team2Name = '';

  List<CategoryModel> allCategories = [];
  List<CategoryModel> team1Picks = [];
  List<CategoryModel> team2Picks = [];
  CategoryModel? team1Banned;
  CategoryModel? team2Banned;

  static const int _picksPerTeam = 4;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadCategories();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await SupabaseRepository.getCategories();
    setState(() {
      allCategories = cats.where((c) => !c.isLocked).toList();
    });
  }

  List<CategoryModel> get available {
    final picked = [...team1Picks, ...team2Picks];
    final banned = [if (team1Banned != null) team1Banned!, if (team2Banned != null) team2Banned!];
    final excluded = [...picked, ...banned].map((c) => c.id).toSet();
    return allCategories.where((c) => !excluded.contains(c.id)).toList();
  }

  List<CategoryModel> get activeCategories {
    final t1 = team1Picks.where((c) => c.id != team2Banned?.id).toList();
    final t2 = team2Picks.where((c) => c.id != team1Banned?.id).toList();
    return [...t1, ...t2];
  }

  void _nextPhase() {
    setState(() => _phase = DraftPhase.values[_phase.index + 1]);
    _animController.reset();
    _animController.forward();
  }

  void _pickCategory(CategoryModel cat) {
    setState(() {
      if (_phase == DraftPhase.team1Pick) {
        if (team1Picks.length < _picksPerTeam) team1Picks.add(cat);
        if (team1Picks.length == _picksPerTeam) _nextPhase();
      } else if (_phase == DraftPhase.team2Pick) {
        if (team2Picks.length < _picksPerTeam) team2Picks.add(cat);
        if (team2Picks.length == _picksPerTeam) _nextPhase();
      }
    });
  }

  void _banCategory(CategoryModel cat) {
    setState(() {
      if (_phase == DraftPhase.team2Ban) {
        team2Banned = cat;
        _nextPhase();
      } else if (_phase == DraftPhase.team1Ban) {
        team1Banned = cat;
        _nextPhase();
      }
    });
  }

  Widget _categoryImage(CategoryModel cat, Color teamColor) {
    final imagePath = _categoryImages[cat.title];
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      child: imagePath != null
          ? Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
          errorBuilder: (_, __, ___) => _emojiPlaceholder(cat.emoji, teamColor))
          : _emojiPlaceholder(cat.emoji, teamColor),
    );
  }

  Widget _emojiPlaceholder(String emoji, Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), _cardBg],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildPhase(),
          ),
        ),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case DraftPhase.enterNames:
        return _buildEnterNames();
      case DraftPhase.team1Pick:
        return _buildPickGrid(
          title: '$team1Name',
          subtitle: 'اختر $_picksPerTeam فئات',
          teamColor: const Color(0xFF2D7A5F),
          picked: team1Picks.length,
          onTap: _pickCategory,
        );
      case DraftPhase.team2Ban:
        return _buildBanGrid(
          title: '$team2Name',
          subtitle: 'امنع فئة من ${team1Name}',
          availableToBan: team1Picks,
        );
      case DraftPhase.team2Pick:
        return _buildPickGrid(
          title: '$team2Name',
          subtitle: 'اختر $_picksPerTeam فئات',
          teamColor: const Color(0xFF8B2635),
          picked: team2Picks.length,
          onTap: _pickCategory,
        );
      case DraftPhase.team1Ban:
        return _buildBanGrid(
          title: '$team1Name',
          subtitle: 'امنع فئة من ${team2Name}',
          availableToBan: team2Picks,
        );
      case DraftPhase.summary:
        return _buildSummary();
    }
  }

  // ===== شاشة إدخال الأسماء =====
  Widget _buildEnterNames() {
    return SingleChildScrollView(
      key: const ValueKey('enterNames'),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // خط زخرفي
          Row(
            children: [
              Expanded(child: Container(height: 0.5, color: _gold.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold)),
              ),
              Expanded(child: Container(height: 0.5, color: _gold.withOpacity(0.3))),
            ],
          ),

          const SizedBox(height: 32),

          // اللوغو
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_goldLight, _gold, Color(0xFF6B4A10)],
            ).createShader(bounds),
            child: const Text('منو أذكى؟',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: 3),
            ),
          ),

          const SizedBox(height: 8),

          Text('ابدأ المباراة',
            style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.8), fontSize: 14, letterSpacing: 4, fontWeight: FontWeight.w300),
          ),

          const SizedBox(height: 32),

          // بطاقة الشرح
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withOpacity(0.3), width: 0.8),
            ),
            child: Column(
              children: [
                _ruleRow('📋', 'كل فريق يختار 4 فئات'),
                const SizedBox(height: 8),
                _ruleRow('🚫', 'كل فريق يمنع فئة من الخصم'),
                const SizedBox(height: 8),
                _ruleRow('⚔️', '6 فئات نشطة في المباراة'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // حقل الفريق الأول
          _luxuryField(_team1Controller, 'الفريق الأول 🔵', const Color(0xFF2D7A5F)),
          const SizedBox(height: 16),
          _luxuryField(_team2Controller, 'الفريق الثاني 🔴', const Color(0xFF8B2635)),

          const SizedBox(height: 32),

          // زر البدء
          GestureDetector(
            onTap: () {
              setState(() {
                team1Name = _team1Controller.text.trim().isEmpty ? 'الفريق الأول' : _team1Controller.text.trim();
                team2Name = _team2Controller.text.trim().isEmpty ? 'الفريق الثاني' : _team2Controller.text.trim();
                _phase = DraftPhase.team1Pick;
              });
              _animController.reset();
              _animController.forward();
            },
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3D2800), Color(0xFFB8890A), Color(0xFFE8C840), Color(0xFFB8890A), Color(0xFF3D2800)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(29),
                boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 25, spreadRadius: 2)],
              ),
              child: const Center(
                child: Text('ابدأ Draft 🎯',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A0E00), letterSpacing: 3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _ruleRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(text,
          style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _luxuryField(TextEditingController ctrl, String hint, Color accent) {
    return TextField(
      controller: ctrl,
      textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 18, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5)),
        filled: true,
        fillColor: _cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _gold, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent.withOpacity(0.4), width: 1)),
      ),
    );
  }

  // ===== شاشة اختيار الفئات =====
  Widget _buildPickGrid({
    required String title,
    required String subtitle,
    required Color teamColor,
    required int picked,
    required Function(CategoryModel) onTap,
  }) {
    return Padding(
      key: ValueKey(_phase),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [

          // هيدر
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withOpacity(0.4), width: 0.8),
            ),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [_goldLight, _gold],
                  ).createShader(bounds),
                  child: Text(title,
                    style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                  style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 13, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                // مؤشر التقدم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_picksPerTeam, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i < picked ? _gold : _gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.78,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: available.length,
              itemBuilder: (ctx, i) {
                final cat = available[i];
                return GestureDetector(
                  onTap: () => onTap(cat),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _gold.withOpacity(0.3), width: 0.8),
                    ),
                    child: Column(
                      children: [
                        Expanded(flex: 3, child: _categoryImage(cat, _gold)),
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: _gold.withOpacity(0.08),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                            ),
                            child: Center(
                              child: Text(cat.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.9), fontSize: 9.5, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== شاشة المنع =====
  Widget _buildBanGrid({
    required String title,
    required String subtitle,
    required List<CategoryModel> availableToBan,
  }) {
    return Padding(
      key: ValueKey(_phase),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // هيدر المنع
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8B2635).withOpacity(0.6), width: 1),
            ),
            child: Column(
              children: [
                const Text('🚫', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [_goldLight, _gold],
                  ).createShader(bounds),
                  child: Text(title,
                    style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle,
                  style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: availableToBan.map((cat) {
              return GestureDetector(
                onTap: () => _banCategory(cat),
                child: Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF8B2635).withOpacity(0.5), width: 0.8),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 80, child: _categoryImage(cat, const Color(0xFF8B2635))),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B2635).withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                        ),
                        child: Text(cat.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===== ملخص المباراة =====
  Widget _buildSummary() {
    final active = activeCategories;
    return Padding(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // هيدر
          Row(
            children: [
              Expanded(child: Container(height: 0.5, color: _gold.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_goldLight, _gold],
                      ).createShader(bounds),
                      child: const Text('فئات المباراة',
                        style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text('${active.length} فئات نشطة',
                      style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.7), fontSize: 12, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container(height: 0.5, color: _gold.withOpacity(0.3))),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: active.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final cat = active[i];
                final fromTeam1 = team1Picks.any((c) => c.id == cat.id);
                final teamColor = fromTeam1 ? const Color(0xFF2D7A5F) : const Color(0xFF8B2635);
                final teamLabel = fromTeam1 ? team1Name : team2Name;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gold.withOpacity(0.2), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(width: 42, height: 42, child: _categoryImage(cat, teamColor)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(cat.title,
                          style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: teamColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: teamColor.withOpacity(0.4)),
                        ),
                        child: Text(teamLabel,
                          style: TextStyle(fontFamily: 'Tajawal', color: teamColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // زر ابدأ
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => WheelScreen(
                    team1Name: team1Name,
                    team2Name: team2Name,
                    team1Categories: team1Picks.where((c) => c.id != team2Banned?.id).toList(),
                    team2Categories: team2Picks.where((c) => c.id != team1Banned?.id).toList(),
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3D2800), Color(0xFFB8890A), Color(0xFFE8C840), Color(0xFFB8890A), Color(0xFF3D2800)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(29),
                boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 25, spreadRadius: 2)],
              ),
              child: const Center(
                child: Text('ابدأ المباراة! 🎮',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A0E00), letterSpacing: 3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}