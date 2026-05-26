// ==============================
// شاشة اختيار المستوى
// اسم الملف: level_screen.dart
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/category_model.dart';
import 'game_screen.dart';

class LevelScreen extends StatefulWidget {
  final CategoryModel category;

  const LevelScreen({
    super.key,
    required this.category,
  });

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {

  // ==============================
  // أسماء الفريقين
  // ==============================
  final _team1Controller = TextEditingController(text: 'الفريق الأول');
  final _team2Controller = TextEditingController(text: 'الفريق الثاني');

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          widget.category.title,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        child: Column(
          children: [

            const SizedBox(height: AppSizes.spaceMD),

            // ==============================
            // صورة أو أيقونة الفئة
            // ==============================
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
                border: Border.all(
                  color: AppColors.cardBorderGold,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glowGold,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.category.imageUrl != null
                    ? Image.network(
                  widget.category.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      widget.category.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                )
                    : Center(
                  child: Text(
                    widget.category.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // اسم الفئة
            Text(
              widget.category.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              widget.category.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontMD,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // ==============================
            // خانات أسماء الفريقين
            // ==============================
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorderGold),
              ),
              child: Column(
                children: [

                  const Text(
                    '👥 أسماء الفريقين',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: AppSizes.fontLG,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceMD),

                  // خانة الفريق الأول
                  TextField(
                    controller: _team1Controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Text(
                        '🔵',
                        style: TextStyle(fontSize: 20),
                      ),
                      labelText: 'اسم الفريق الأول',
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceMD),

                  // VS
                  const Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceMD),

                  // خانة الفريق الثاني
                  TextField(
                    controller: _team2Controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Text(
                        '🔴',
                        style: TextStyle(fontSize: 20),
                      ),
                      labelText: 'اسم الفريق الثاني',
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: AppSizes.spaceXXL),

            // ==============================
            // أزرار المستويات
            // ==============================
            const Text(
              'اختر المستوى',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontLG,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: AppSizes.spaceMD),

            _LevelButton(
              level: 1,
              title: 'المستوى الأول',
              points: '٢٠٠ نقطة',
              color: AppColors.level1,
              emoji: '🟢',
              category: widget.category,
              team1: _team1Controller,
              team2: _team2Controller,
            ),

            const SizedBox(height: AppSizes.spaceMD),

            _LevelButton(
              level: 2,
              title: 'المستوى الثاني',
              points: '٤٠٠ نقطة',
              color: AppColors.level2,
              emoji: '🟡',
              category: widget.category,
              team1: _team1Controller,
              team2: _team2Controller,
            ),

            const SizedBox(height: AppSizes.spaceMD),

            _LevelButton(
              level: 3,
              title: 'المستوى الثالث',
              points: '٦٠٠ نقطة',
              color: AppColors.level3,
              emoji: '🔴',
              category: widget.category,
              team1: _team1Controller,
              team2: _team2Controller,
            ),

            const SizedBox(height: AppSizes.spaceLG),

          ],
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int level;
  final String title;
  final String points;
  final Color color;
  final String emoji;
  final CategoryModel category;
  final TextEditingController team1;
  final TextEditingController team2;

  const _LevelButton({
    required this.level,
    required this.title,
    required this.points,
    required this.color,
    required this.emoji,
    required this.category,
    required this.team1,
    required this.team2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              level: level,
              category: category,
              team1Name: team1.text.trim().isEmpty
                  ? 'الفريق الأول'
                  : team1.text.trim(),
              team2Name: team2.text.trim().isEmpty
                  ? 'الفريق الثاني'
                  : team2.text.trim(),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSizes.spaceMD),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceMD,
                vertical: AppSizes.spaceSM,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                points,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontMD,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}