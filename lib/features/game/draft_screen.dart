// ==============================
// ط´ط§ط´ط© Draft ط§ظ„ظپط¦ط§طھ â€” Luxury Theme
// ط§ط³ظ… ط§ظ„ظ…ظ„ظپ: draft_screen.dart
// ==============================

import 'wheel_screen.dart';
import '../../data/repositories/supabase_repository.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/categories_data.dart';
import '../../data/models/category_model.dart';
import 'match_board_screen.dart';

const Map<String, String> _categoryImages = {
  'ط§ظ„ط­ط±ط¨ ط§ظ„ط¹ط§ظ„ظ…ظٹط©': 'assets/images/categories/harb.png',
  'ظƒط±ط© ظ‚ط¯ظ… ط¹ط§ظ„ظ…ظٹط©': 'assets/images/categories/koora.png',
  'ط§ظ„ط£ظƒظ„ط§طھ ط§ظ„ط¹ط§ظ„ظ…ظٹط©': 'assets/images/categories/aklat.png',
  'ظƒط£ط³ ط§ظ„ط¹ط§ظ„ظ…': 'assets/images/categories/kas.png',
  'ط±ظٹط§ط¶ط©': 'assets/images/categories/riyada.png',
  'ط³ط¨ظٹط³طھظˆظ†': 'assets/images/categories/siston.png',
  'ط§ظ„ط³ظˆط´ظ„ ظ…ظٹط¯ظٹط§': 'assets/images/categories/social.png',
  'ط´ط®طµظٹط§طھ ظˆط±ظ…ظˆط²': 'assets/images/categories/characters.png',
  'ظ…ط³ظ„ط³ظ„ط§طھ': 'assets/images/categories/mosalsal.png',
  'ط£ظپظ„ط§ظ…': 'assets/images/categories/aflam.png',
  'ط®ط±ط§ظٹط·': 'assets/images/categories/maps.png',
  'ظ…ظ† ظ‚ط§ظ„ ظ‡ط°ظ‡ ط§ظ„ظ…ظ‚ظˆظ„ط©': 'assets/images/categories/maqola.png',
  'ظ‚طµطµ ط§ظ„ط£ظ†ط¨ظٹط§ط،': 'assets/images/categories/anbiya.png',
  'ظ…ظ†طھط¬ط§طھ': 'assets/images/categories/products.png',
  'ط·ط¨ظٹط¹طھ': 'assets/images/categories/tabea.png',
  'ط§ظ„ط³ط¹ظˆط¯ظٹط©': 'assets/images/categories/saudi.png',
  'ط´ط؛ظ„ ظ…ط®ظƒ': 'assets/images/categories/shoghl.png',
  'ط£ظ…ط«ط§ظ„ ظˆط£ظ„ط؛ط§ط²': 'assets/images/categories/amthal.png',
  'ط§ظ„ظƒظˆظٹطھ': 'assets/images/categories/kuwait.png',
  'ظƒطھط¨ ظˆط±ظˆط§ظٹط§طھ': 'assets/images/categories/kutub.png',
  'ط®ظ…ظ† ط§ظ„ط´ط®طµظٹط© ظ…ظ† طµظˆط±ط©/ظپظٹط¯ظٹظˆ AI': 'assets/images/categories/ai.png',
  'ظ…ط¹ظ„ظˆظ…ط§طھ ط¹ط§ظ…ط©': 'assets/images/categories/general.png',
  'ظ…ط­ظ…ط¯ ط§ظ„ظپط§طھط­': 'assets/images/categories/fatih.png',
  'ط§ظ„طµط­ط§ط¨ط©': 'assets/images/categories/sahaba.png',
  'ط§ظ„ط®ظ„ظٹط¬ ط§ظ„ط¹ط±ط¨ظٹ': 'assets/images/categories/gulf.png',
  'ط§ظƒطھط´ظپ ط§ظ„ط®ط·': 'assets/images/categories/khat.png',
  'ط§ط®طھط±ط§ط¹ط§طھ': 'assets/images/categories/ikhtiraat.png',
  'ظ…ط³ظ„ط³ظ„ط§طھ طھط§ط±ظٹط®ظٹط©': 'assets/images/categories/tarikh.png',
  'ظپظ† ط®ظ„ظٹط¬ظٹ': 'assets/images/categories/fan.png',
  'ط¨ظ†ط§طھ ظˆط¨ط³': 'assets/images/categories/banat.png',
  'ط§ظ†ظ…ظٹ': 'assets/images/categories/japan.png',
  'ط¹ط§ظ„ظ… ط§ظ„ط­ظٹظˆط§ظ†': 'assets/images/categories/animals.png',
  'ط§ظƒظ…ظ„ ط§ظ„ط¬ظ…ظ„ط©': 'assets/images/categories/jumla.png',
  'ط£ط¹ظ„ط§ظ… ظˆط´ط¹ط§ط±ط§طھ': 'assets/images/categories/flags.png',
  'ظ„ط؛ط© ظˆط£ط¯ط¨ ظˆط´ط¹ط±': 'assets/images/categories/luga.png',
  'ظ…ط¹ط§ظ„ظ… ط¯ظˆظ„': 'assets/images/categories/maalim.png',
  'ط§ظ„ظƒظ„ط§ط³ظٹظƒظˆ': 'assets/images/categories/classico.png',
  'ط­ط¶ط§ط±ط§طھ ظˆط¯ظˆظ„': 'assets/images/categories/hisabat.png',
  'ط³ظٹط§ط±ط§طھ': 'assets/images/categories/cars.png',
  'ط¹ط¬ط§ط¦ط¨ ط§ظ„ط¹ط§ظ„ظ…': 'assets/images/categories/ajayeb.png',
  'ط£ظ‡ظ„ ط§ظ„ط¨ظٹطھ': 'assets/images/categories/ahlbayt.png',
  'ط·ط±ط¨ظٹط§طھ': 'assets/images/categories/tarb.png',
};

// ط£ظ„ظˆط§ظ† ط§ظ„ط«ظٹظ… ط§ظ„ظپط§ط®ط±
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

  final _team1Controller = TextEditingController(text: 'ط§ظ„ظپط±ظٹظ‚ ط§ظ„ط£ظˆظ„');
  final _team2Controller = TextEditingController(text: 'ط§ظ„ظپط±ظٹظ‚ ط§ظ„ط«ط§ظ†ظٹ');

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
    // ✅ أولاً جرّب imageUrl من Supabase
    if (cat.imageUrl != null && cat.imageUrl!.isNotEmpty && _categoryImages[cat.title] == null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: Image.network(cat.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
          errorBuilder: (_, __, ___) => _emojiPlaceholder(cat.emoji, teamColor)),
      );
    }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _phase != DraftPhase.enterNames ? GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _gold.withOpacity(0.3))),
            child: Icon(Icons.arrow_back_ios_rounded, color: _gold.withOpacity(0.7), size: 16),
          ),
        ) : null,
      ),
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
          subtitle: 'ط§ط®طھط± $_picksPerTeam ظپط¦ط§طھ',
          teamColor: const Color(0xFF2D7A5F),
          picked: team1Picks.length,
          onTap: _pickCategory,
        );
      case DraftPhase.team2Ban:
        return _buildBanGrid(
          title: '$team2Name',
          subtitle: 'ط§ظ…ظ†ط¹ ظپط¦ط© ظ…ظ† ${team1Name}',
          availableToBan: team1Picks,
        );
      case DraftPhase.team2Pick:
        return _buildPickGrid(
          title: '$team2Name',
          subtitle: 'ط§ط®طھط± $_picksPerTeam ظپط¦ط§طھ',
          teamColor: const Color(0xFF8B2635),
          picked: team2Picks.length,
          onTap: _pickCategory,
        );
      case DraftPhase.team1Ban:
        return _buildBanGrid(
          title: '$team1Name',
          subtitle: 'ط§ظ…ظ†ط¹ ظپط¦ط© ظ…ظ† ${team2Name}',
          availableToBan: team2Picks,
        );
      case DraftPhase.summary:
        return _buildSummary();
    }
  }

  // ===== ط´ط§ط´ط© ط¥ط¯ط®ط§ظ„ ط§ظ„ط£ط³ظ…ط§ط، =====
  Widget _buildEnterNames() {
    return SingleChildScrollView(
      key: const ValueKey('enterNames'),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // ط®ط· ط²ط®ط±ظپظٹ
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

          // ط§ظ„ظ„ظˆط؛ظˆ
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_goldLight, _gold, Color(0xFF6B4A10)],
            ).createShader(bounds),
            child: const Text('ظ…ظ†ظˆ ط£ط°ظƒظ‰طں',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: 3),
            ),
          ),

          const SizedBox(height: 8),

          Text('ط§ط¨ط¯ط£ ط§ظ„ظ…ط¨ط§ط±ط§ط©',
            style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.8), fontSize: 14, letterSpacing: 4, fontWeight: FontWeight.w300),
          ),

          const SizedBox(height: 32),

          // ط¨ط·ط§ظ‚ط© ط§ظ„ط´ط±ط­
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
                _ruleRow('ًں“‹', 'ظƒظ„ ظپط±ظٹظ‚ ظٹط®طھط§ط± 4 ظپط¦ط§طھ'),
                const SizedBox(height: 8),
                _ruleRow('ًںڑ«', 'ظƒظ„ ظپط±ظٹظ‚ ظٹظ…ظ†ط¹ ظپط¦ط© ظ…ظ† ط§ظ„ط®طµظ…'),
                const SizedBox(height: 8),
                _ruleRow('âڑ”ï¸ڈ', '6 ظپط¦ط§طھ ظ†ط´ط·ط© ظپظٹ ط§ظ„ظ…ط¨ط§ط±ط§ط©'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ط­ظ‚ظ„ ط§ظ„ظپط±ظٹظ‚ ط§ظ„ط£ظˆظ„
          _luxuryField(_team1Controller, 'ط§ظ„ظپط±ظٹظ‚ ط§ظ„ط£ظˆظ„ ًں”µ', const Color(0xFF2D7A5F)),
          const SizedBox(height: 16),
          _luxuryField(_team2Controller, 'ط§ظ„ظپط±ظٹظ‚ ط§ظ„ط«ط§ظ†ظٹ ًں”´', const Color(0xFF8B2635)),

          const SizedBox(height: 32),

          // ط²ط± ط§ظ„ط¨ط¯ط،
          GestureDetector(
            onTap: () {
              setState(() {
                team1Name = _team1Controller.text.trim().isEmpty ? 'ط§ظ„ظپط±ظٹظ‚ ط§ظ„ط£ظˆظ„' : _team1Controller.text.trim();
                team2Name = _team2Controller.text.trim().isEmpty ? 'ط§ظ„ظپط±ظٹظ‚ ط§ظ„ط«ط§ظ†ظٹ' : _team2Controller.text.trim();
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
                child: Text('ط§ط¨ط¯ط£ Draft ًںژ¯',
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

  // ===== ط´ط§ط´ط© ط§ط®طھظٹط§ط± ط§ظ„ظپط¦ط§طھ =====
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

          // ظ‡ظٹط¯ط±
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
                // ظ…ط¤ط´ط± ط§ظ„طھظ‚ط¯ظ…
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

  // ===== ط´ط§ط´ط© ط§ظ„ظ…ظ†ط¹ =====
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

          // ظ‡ظٹط¯ط± ط§ظ„ظ…ظ†ط¹
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
                const Text('ًںڑ«', style: TextStyle(fontSize: 32)),
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

  // ===== ظ…ظ„ط®طµ ط§ظ„ظ…ط¨ط§ط±ط§ط© =====
  Widget _buildSummary() {
    final active = activeCategories;
    return Padding(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // ظ‡ظٹط¯ط±
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
                      child: const Text('ظپط¦ط§طھ ط§ظ„ظ…ط¨ط§ط±ط§ط©',
                        style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text('${active.length} ظپط¦ط§طھ ظ†ط´ط·ط©',
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

          // ط²ط± ط§ط¨ط¯ط£
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
                child: Text('ط§ط¨ط¯ط£ ط§ظ„ظ…ط¨ط§ط±ط§ط©! ًںژ®',
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
