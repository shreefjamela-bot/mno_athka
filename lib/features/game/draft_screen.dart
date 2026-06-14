// ==============================
// شاشة Draft الفئات
// اسم الملف: draft_screen.dart
// المكان: lib/features/game/
// ==============================

import 'wheel_screen.dart';
import '../../data/repositories/supabase_repository.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/categories_data.dart';
import '../../data/models/category_model.dart';
import 'match_board_screen.dart';

// ==============================
// خريطة صور الفئات
// ==============================
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

class _DraftScreenState extends State<DraftScreen> {
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

  // ── عدد الاختيارات المطلوبة لكل فريق ───────────
  static const int _picksPerTeam = 4;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await SupabaseRepository.getCategories();
    setState(() {
      allCategories = cats.where((c) => !c.isLocked).toList();
    });
  }

  List<CategoryModel> get available {
    final picked = [...team1Picks, ...team2Picks];
    final banned = [
      if (team1Banned != null) team1Banned!,
      if (team2Banned != null) team2Banned!,
    ];
    final excluded = [...picked, ...banned].map((c) => c.id).toSet();
    return allCategories.where((c) => !excluded.contains(c.id)).toList();
  }

  List<CategoryModel> get activeCategories {
    final t1 = team1Picks.where((c) => c.id != team2Banned?.id).toList();
    final t2 = team2Picks.where((c) => c.id != team1Banned?.id).toList();
    return [...t1, ...t2];
  }

  void _nextPhase() => setState(() {
    _phase = DraftPhase.values[_phase.index + 1];
  });

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
      borderRadius:
      const BorderRadius.vertical(top: Radius.circular(14)),
      child: imagePath != null
          ? Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) =>
            _emojiPlaceholder(cat.emoji, teamColor),
      )
          : _emojiPlaceholder(cat.emoji, teamColor),
    );
  }

  Widget _emojiPlaceholder(String emoji, Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            AppColors.surfaceColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 36)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildPhase(),
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
          title: '$team1Name — اختر $_picksPerTeam فئات',
          subtitle: 'اختيارات: ${team1Picks.length}/$_picksPerTeam',
          teamColor: AppColors.team1Color,
          onTap: _pickCategory,
        );
      case DraftPhase.team2Ban:
        return _buildBanGrid(
          title: '$team2Name — امنع فئة واحدة',
          subtitle: 'اختر فئة تمنعها من $team1Name',
          banColor: AppColors.dangerRed,
          availableToBan: team1Picks,
        );
      case DraftPhase.team2Pick:
        return _buildPickGrid(
          title: '$team2Name — اختر $_picksPerTeam فئات',
          subtitle: 'اختيارات: ${team2Picks.length}/$_picksPerTeam',
          teamColor: AppColors.team2Color,
          onTap: _pickCategory,
        );
      case DraftPhase.team1Ban:
        return _buildBanGrid(
          title: '$team1Name — امنع فئة واحدة',
          subtitle: 'اختر فئة تمنعها من $team2Name',
          banColor: AppColors.dangerRed,
          availableToBan: team2Picks,
        );
      case DraftPhase.summary:
        return _buildSummary();
    }
  }

  Widget _buildEnterNames() {
    return Padding(
      key: const ValueKey('enterNames'),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
            ).createShader(bounds),
            child: const Text(
              'منو أذكى؟',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ادخل أسماء الفريقين للبدء',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 12),
          // شرح آلية اللعب
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorderGold),
            ),
            child: const Text(
              '📋 كل فريق يختار 4 فئات\n🚫 كل فريق يمنع فئة من الفريق الآخر\n⚔️ النتيجة: 6 فئات في المباراة',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _nameField(
              _team1Controller, 'الفريق الأول', AppColors.team1Color),
          const SizedBox(height: 16),
          _nameField(
              _team2Controller, 'الفريق الثاني', AppColors.team2Color),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                shadowColor: AppColors.glowGold,
                elevation: 8,
              ),
              onPressed: () {
                setState(() {
                  team1Name = _team1Controller.text.trim().isEmpty
                      ? 'الفريق الأول'
                      : _team1Controller.text.trim();
                  team2Name = _team2Controller.text.trim().isEmpty
                      ? 'الفريق الثاني'
                      : _team2Controller.text.trim();
                  _phase = DraftPhase.team1Pick;
                });
              },
    child: const Text(
    'ابدأ Draft — منع فئة 🎯',
    style: TextStyle(
    fontSize: 20,
    color: AppColors.background,
    fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameField(
      TextEditingController ctrl, String hint, Color accent) {
    return TextField(
      controller: ctrl,
      textAlign: TextAlign.center,
      style: const TextStyle(
          color: AppColors.textPrimary, fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: accent.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPickGrid({
    required String title,
    required String subtitle,
    required Color teamColor,
    required Function(CategoryModel) onTap,
  }) {
    return Padding(
      key: ValueKey(_phase),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: teamColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: teamColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: teamColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: teamColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13),
                ),
                const SizedBox(height: 8),
                // مؤشر التقدم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_picksPerTeam, (i) {
                    final picked = _phase == DraftPhase.team1Pick
                        ? team1Picks.length
                        : team2Picks.length;
                    return Container(
                      width: 28,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i < picked
                            ? teamColor
                            : teamColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
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
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: teamColor.withOpacity(0.4),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: teamColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _categoryImage(cat, teamColor),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: teamColor.withOpacity(0.15),
                              borderRadius:
                              const BorderRadius.vertical(
                                  bottom: Radius.circular(14)),
                            ),
                            child: Center(
                              child: Text(
                                cat.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: teamColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
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

  Widget _buildBanGrid({
    required String title,
    required String subtitle,
    required Color banColor,
    required List<CategoryModel> availableToBan,
  }) {
    return Padding(
      key: ValueKey(_phase),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: banColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: banColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: banColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: banColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: banColor.withOpacity(0.5),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: banColor.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80,
                        child: _categoryImage(cat, banColor),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: banColor.withOpacity(0.15),
                          borderRadius:
                          const BorderRadius.vertical(
                              bottom: Radius.circular(14)),
                        ),
                        child: Text(
                          cat.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: banColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildSummary() {
    final active = activeCategories;
    return Padding(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
            ).createShader(bounds),
            child: const Text(
              '🏆 فئات المباراة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${active.length} فئات نشطة',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: active.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final cat = active[i];
                final fromTeam1 =
                team1Picks.any((c) => c.id == cat.id);
                final teamColor = fromTeam1
                    ? AppColors.team1Color
                    : AppColors.team2Color;
                final teamLabel =
                fromTeam1 ? team1Name : team2Name;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: teamColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: teamColor.withOpacity(0.5),
                        width: 1.5),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: _categoryImage(cat, teamColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat.title,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: teamColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: teamColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          teamLabel,
                          style: TextStyle(
                              color: teamColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                shadowColor: AppColors.glowGold,
                elevation: 8,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WheelScreen(
                      team1Name: team1Name,
                      team2Name: team2Name,
                      team1Categories: team1Picks
                          .where((c) => c.id != team2Banned?.id)
                          .toList(),
                      team2Categories: team2Picks
                          .where((c) => c.id != team1Banned?.id)
                          .toList(),
                    ),
                  ),
                );
              },
              child: const Text(
                'ابدأ المباراة! 🎮',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
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