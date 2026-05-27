// ==============================
// شاشة اختيار الفئات للفريقين
// اسم الملف: team_selection_screen.dart
// المكان: lib/features/game/
//
// كل فريق يختار ٤ فئات
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/supabase_repository.dart';
import 'match_board_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  final String team1Name;
  final String team2Name;

  const TeamSelectionScreen({
    super.key,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {

  List<CategoryModel> _allCategories = [];
  bool _isLoading = true;

  // فئات كل فريق — أقصى ٤ لكل فريق
  List<String> _team1Selected = [];
  List<String> _team2Selected = [];

  // الفريق الحالي اللي يختار — ١ أو ٢
  int _currentTeam = 1;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await SupabaseRepository.getCategories();
    setState(() {
      // نشيل المقفلة
      _allCategories = categories
          .where((c) => !c.isLocked)
          .toList();
      _isLoading = false;
    });
  }

  // ==============================
  // هل الفئة محددة من أي فريق
  // ==============================
  bool _isSelectedByTeam1(String id) => _team1Selected.contains(id);
  bool _isSelectedByTeam2(String id) => _team2Selected.contains(id);
  bool _isSelected(String id) =>
      _isSelectedByTeam1(id) || _isSelectedByTeam2(id);

  // ==============================
  // اختيار أو إلغاء فئة
  // ==============================
  void _toggleCategory(CategoryModel category) {
    final id = category.id;

    setState(() {
      if (_currentTeam == 1) {
        if (_team1Selected.contains(id)) {
          _team1Selected.remove(id);
        } else if (_team1Selected.length < 4) {
          _team1Selected.add(id);
        }
      } else {
        if (_team2Selected.contains(id)) {
          _team2Selected.remove(id);
        } else if (_team2Selected.length < 4 &&
            !_team1Selected.contains(id)) {
          _team2Selected.add(id);
        }
      }
    });
  }

  // ==============================
  // الانتقال لشاشة اللوحة
  // ==============================
  void _startGame() {
    final team1Categories = _allCategories
        .where((c) => _team1Selected.contains(c.id))
        .toList();
    final team2Categories = _allCategories
        .where((c) => _team2Selected.contains(c.id))
        .toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MatchBoardScreen(
          team1Name: widget.team1Name,
          team2Name: widget.team2Name,
          team1Categories: team1Categories,
          team2Categories: team2Categories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSelected =
    _currentTeam == 1 ? _team1Selected : _team2Selected;
    final remaining = 4 - currentSelected.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          _currentTeam == 1
              ? '🔵 ${widget.team1Name} يختار'
              : '🔴 ${widget.team2Name} يختار',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [

          // ==============================
          // شريط الحالة
          // ==============================
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorderGold),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                // الفريق ١
                Column(
                  children: [
                    Text(
                      '🔵 ${widget.team1Name}',
                      style: TextStyle(
                        color: _currentTeam == 1
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_team1Selected.length}/4',
                      style: TextStyle(
                        color: _currentTeam == 1
                            ? AppColors.correct
                            : AppColors.textHint,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // فاصل
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.cardBorder,
                ),

                // الفريق ٢
                Column(
                  children: [
                    Text(
                      '🔴 ${widget.team2Name}',
                      style: TextStyle(
                        color: _currentTeam == 2
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_team2Selected.length}/4',
                      style: TextStyle(
                        color: _currentTeam == 2
                            ? AppColors.correct
                            : AppColors.textHint,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

          // رسالة التوجيه
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              remaining > 0
                  ? 'اختر $remaining فئة أخرى'
                  : 'ممتاز! اضغط التالي',
              style: TextStyle(
                color: remaining > 0
                    ? AppColors.textSecondary
                    : AppColors.correct,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ==============================
          // شبكة الفئات
          // ==============================
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: _allCategories.length,
              itemBuilder: (context, index) {
                final category = _allCategories[index];
                final byTeam1 = _isSelectedByTeam1(category.id);
                final byTeam2 = _isSelectedByTeam2(category.id);
                final isDisabled = _currentTeam == 2 && byTeam1;

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () => _toggleCategory(category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: byTeam1
                          ? AppColors.correct.withOpacity(0.2)
                          : byTeam2
                          ? AppColors.wrong.withOpacity(0.2)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: byTeam1
                            ? AppColors.correct
                            : byTeam2
                            ? AppColors.wrong
                            : isDisabled
                            ? AppColors.textHint
                            : AppColors.cardBorder,
                        width: byTeam1 || byTeam2 ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // الصورة أو الأيقونة
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: category.imageUrl != null
                              ? Image.network(
                            category.imageUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          )
                              : Text(
                            category.emoji,
                            style:
                            const TextStyle(fontSize: 28),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // اسم الفئة
                        Text(
                          category.title,
                          style: TextStyle(
                            color: isDisabled
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // علامة الاختيار
                        if (byTeam1 || byTeam2)
                          Text(
                            byTeam1 ? '🔵' : '🔴',
                            style: const TextStyle(fontSize: 10),
                          ),

                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ==============================
          // زر التالي
          // ==============================
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                if (_currentTeam == 1 &&
                    _team1Selected.length == 4) {
                  // انتقل للفريق ٢
                  setState(() => _currentTeam = 2);
                } else if (_currentTeam == 2 &&
                    _team2Selected.length == 4) {
                  // ابدأ اللعبة
                  _startGame();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: ((_currentTeam == 1 &&
                      _team1Selected.length == 4) ||
                      (_currentTeam == 2 &&
                          _team2Selected.length == 4))
                      ? const LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  )
                      : null,
                  color: ((_currentTeam == 1 &&
                      _team1Selected.length == 4) ||
                      (_currentTeam == 2 &&
                          _team2Selected.length == 4))
                      ? null
                      : AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ((_currentTeam == 1 &&
                        _team1Selected.length == 4) ||
                        (_currentTeam == 2 &&
                            _team2Selected.length == 4))
                        ? Colors.transparent
                        : AppColors.cardBorder,
                  ),
                ),
                child: Center(
                  child: Text(
                    _currentTeam == 1
                        ? _team1Selected.length == 4
                        ? 'التالي — ${widget.team2Name} 🔴'
                        : 'اختر ${4 - _team1Selected.length} فئة'
                        : _team2Selected.length == 4
                        ? 'ابدأ اللعبة! 🎮'
                        : 'اختر ${4 - _team2Selected.length} فئة',
                    style: TextStyle(
                      color: ((_currentTeam == 1 &&
                          _team1Selected.length == 4) ||
                          (_currentTeam == 2 &&
                              _team2Selected.length == 4))
                          ? AppColors.background
                          : AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
}