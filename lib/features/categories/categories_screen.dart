// ==============================
// شاشة الفئات
// اسم الملف: categories_screen.dart
// المكان: lib/features/categories/
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

  // قائمة الفئات
  List<CategoryModel> _categories = [];

  // هل يحمّل
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // ==============================
  // جيب الفئات من Supabase
  // ==============================
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
          'اختر الفئة',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
      // شاشة التحميل
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
      // إذا ما في فئات
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
              'الفئات المتاحة',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontLG,
              ),
            ),
            const SizedBox(height: AppSizes.spaceMD),
            Expanded(
              child: GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.spaceMD,
                  mainAxisSpacing: AppSizes.spaceMD,
                  childAspectRatio: 1.1,
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

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (category.isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('هذه الفئة مقفلة حالياً'),
              backgroundColor: AppColors.wrong,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: category.isLocked
                ? AppColors.textHint
                : AppColors.primary,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.isLocked ? '🔒' : category.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: AppSizes.spaceSM),
            Text(
              category.title,
              style: TextStyle(
                color: category.isLocked
                    ? AppColors.textHint
                    : AppColors.textPrimary,
                fontSize: AppSizes.fontLG,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceXS),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceSM),
              child: Text(
                category.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontSM,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}