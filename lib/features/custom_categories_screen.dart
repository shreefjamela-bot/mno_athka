// ==============================
// شاشة إنشاء فئات وأسئلة خاصة
// اسم الملف: custom_categories_screen.dart
// ==============================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';

class CustomCategoriesScreen extends StatefulWidget {
  const CustomCategoriesScreen({super.key});

  @override
  State<CustomCategoriesScreen> createState() =>
      _CustomCategoriesScreenState();
}

class _CustomCategoriesScreenState
    extends State<CustomCategoriesScreen> {

  final _emailController = TextEditingController();
  final _categoryTitleController = TextEditingController();
  String _selectedEmoji = '🎯';
  bool _isLoading = false;
  bool _categoryCreated = false;
  String? _createdCategoryId;
  String? _createdCategoryTitle;

  // أسئلة الفئة
  final List<Map<String, dynamic>> _questions = [];
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  int _questionLevel = 1;

  final List<String> _emojis = [
    '🎯', '🌍', '⚽', '🎵', '📚', '🔬', '🏆',
    '🎮', '🌙', '⭐', '🦁', '🌺', '🎨', '🚀',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _categoryTitleController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    if (_categoryTitleController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('custom_categories')
          .insert({
        'user_email': _emailController.text.trim(),
        'title': _categoryTitleController.text.trim(),
        'emoji': _selectedEmoji,
      })
          .select()
          .single();

      setState(() {
        _isLoading = false;
        _categoryCreated = true;
        _createdCategoryId = response['id'];
        _createdCategoryTitle = _categoryTitleController.text.trim();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ، تأكد من البريد الإلكتروني'),
            backgroundColor: AppColors.wrong,
          ),
        );
      }
    }
  }

  Future<void> _addQuestion() async {
    if (_questionController.text.trim().isEmpty ||
        _answerController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client
          .from('custom_questions')
          .insert({
        'category_id': _createdCategoryId,
        'user_email': _emailController.text.trim(),
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
        'level': _questionLevel,
      });

      setState(() {
        _isLoading = false;
        _questions.add({
          'question': _questionController.text.trim(),
          'answer': _answerController.text.trim(),
          'level': _questionLevel,
        });
        _questionController.clear();
        _answerController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إضافة السؤال'),
            backgroundColor: AppColors.correct,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'فئتي الخاصة',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _categoryCreated
            ? _buildAddQuestions()
            : _buildCreateCategory(),
      ),
    );
  }

  // ── إنشاء الفئة ─────────────────────────────────
  Widget _buildCreateCategory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorderGold),
              boxShadow: [
                BoxShadow(color: AppColors.glowGold, blurRadius: 12),
              ],
            ),
            child: const Column(
              children: [
                Text('🗂️', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text(
                  'أنشئ فئتك الخاصة',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'أنشئ فئة بأسئلتك الخاصة وشاركها مع أصدقائك\nستصلك على بريدك الإلكتروني',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildLabel('بريدك الإلكتروني *'),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('example@email.com'),
          ),

          const SizedBox(height: 20),

          _buildLabel('اسم الفئة *'),
          const SizedBox(height: 8),
          TextField(
            controller: _categoryTitleController,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('مثال: أسئلة العائلة'),
          ),

          const SizedBox(height: 20),

          _buildLabel('اختر إيموجي للفئة'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emojis.map((emoji) {
              final isSelected = _selectedEmoji == emoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _createCategory,
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.background,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'أنشئ الفئة 🗂️',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── إضافة أسئلة ─────────────────────────────────
  Widget _buildAddQuestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // هيدر الفئة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.correct.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.correct, width: 1.5),
            ),
            child: Row(
              children: [
                Text(_selectedEmoji,
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _createdCategoryTitle ?? '',
                        style: const TextStyle(
                          color: AppColors.correct,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_questions.length} سؤال مضاف',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle,
                    color: AppColors.correct, size: 24),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildLabel('السؤال *'),
          const SizedBox(height: 8),
          TextField(
            controller: _questionController,
            textAlign: TextAlign.right,
            maxLines: 2,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('اكتب السؤال...'),
          ),

          const SizedBox(height: 16),

          _buildLabel('الإجابة *'),
          const SizedBox(height: 8),
          TextField(
            controller: _answerController,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('اكتب الإجابة...'),
          ),

          const SizedBox(height: 16),

          _buildLabel('المستوى'),
          const SizedBox(height: 8),
          Row(
            children: [1, 2, 3].map((level) {
              final labels = {1: '200', 2: '400', 3: '600'};
              final isSelected = _questionLevel == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _questionLevel = level),
                  child: Container(
                    margin: EdgeInsets.only(left: level < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      labels[level]!,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _addQuestion,
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.background,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'أضف السؤال ➕',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (_questions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'الأسئلة المضافة (${_questions.length})',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_questions.asMap().entries.map((e) {
              final i = e.key;
              final q = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['question'],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '✅ ${q['answer']}',
                            style: const TextStyle(
                              color: AppColors.correct,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: AppColors.textHint, fontSize: 13),
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}