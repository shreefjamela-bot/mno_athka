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
        if (team1Picks.length < 3) team1Picks.add(cat);
        if (team1Picks.length == 3) _nextPhase();
      } else if (_phase == DraftPhase.team2Pick) {
        if (team2Picks.length < 3) team2Picks.add(cat);
        if (team2Picks.length == 3) _nextPhase();
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
          title: '$team1Name — اختر 3 فئات',
          subtitle: 'اختيارات: ${team1Picks.length}/3',
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
          title: '$team2Name — اختر 3 فئات',
          subtitle: 'اختيارات: ${team2Picks.length}/3',
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

  // ── شاشة إدخال الأسماء ──────────────────────────────
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 48),
          _nameField(
              _team1Controller, 'الفريق الأول', AppColors.team1Color),
          const SizedBox(height: 16),
          _nameField(
              _team2Controller, 'الفريق الثاني', AppColors.team2Color),
          const SizedBox(height: 48),
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
                'ابدأ Draft 🎯',
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
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
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
          borderSide:
          BorderSide(color: accent.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }

  // ── شبكة الاختيار ───────────────────────────────────
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

          // هيدر الفريق
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
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // شبكة الفئات
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
                        // صورة/إيموجي الفئة
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    teamColor.withOpacity(0.15),
                                    AppColors.surfaceColor,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  cat.emoji,
                                  style:
                                  const TextStyle(fontSize: 36),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // اسم الفئة
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

  // ── شبكة المنع ──────────────────────────────────────
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
                      color: AppColors.textSecondary, fontSize: 13),
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
                        color: banColor.withOpacity(0.5), width: 1.5),
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
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: Container(
                          height: 70,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                banColor.withOpacity(0.15),
                                AppColors.surfaceColor,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat.emoji,
                              style: const TextStyle(fontSize: 34),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: banColor.withOpacity(0.15),
                          borderRadius: const BorderRadius.vertical(
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

  // ── شاشة الملخص النهائي ─────────────────────────────
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
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: teamColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: teamColor.withOpacity(0.5),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: teamColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(cat.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          cat.title,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16),
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