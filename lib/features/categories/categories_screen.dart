// ==============================
// شاشة الفئات — Premium Theme
// اسم الملف: categories_screen.dart
// ==============================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/supabase_repository.dart';
import '../game/level_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await SupabaseRepository.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'اختر فئتك',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : _categories.isEmpty
          ? const Center(
        child: Text(
          'ما في فئات متاحة',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختر موضوعك وابدأ التحدي',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontMD,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSizes.spaceMD),
            Expanded(
              child: GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _CategoryCard(category: category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (category.isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('هذه الفئة مقفلة حالياً 🔒'),
              backgroundColor: AppColors.wrong.withOpacity(0.8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LevelScreen(category: category),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: category.isLocked
                  ? AppColors.textHint
                  : AppColors.cardBorderGold,
              width: 1,
            ),
            boxShadow: category.isLocked
                ? []
                : [
              BoxShadow(
                color: AppColors.glowGold,
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ==============================
              // صورة الفئة أو الأيقونة
              // ==============================
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: category.isLocked
                      ? AppColors.surfaceColor
                      : AppColors.primary.withOpacity(0.15),
                  border: Border.all(
                    color: category.isLocked
                        ? AppColors.textHint
                        : AppColors.cardBorderGold,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: category.isLocked
                  // مقفلة — أيقونة قفل
                      ? const Icon(
                    Icons.lock,
                    color: AppColors.textHint,
                    size: 30,
                  )
                      : category.imageUrl != null
                  // عندها صورة — نعرضها
                      ? Image.network(
                    category.imageUrl!,
                    fit: BoxFit.cover,
                    width: 70,
                    height: 70,
                    // لما الصورة تحمّل
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    // لو الصورة ما حملت
                    errorBuilder: (context, error, stack) {
                      return Center(
                        child: Text(
                          category.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      );
                    },
                  )
                  // ما عندها صورة — أيقونة
                      : Center(
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // اسم الفئة
              Text(
                category.title,
                style: TextStyle(
                  color: category.isLocked
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                  fontSize: AppSizes.fontMD,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // وصف الفئة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.description,
                  style: TextStyle(
                    color: category.isLocked
                        ? AppColors.textHint
                        : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}